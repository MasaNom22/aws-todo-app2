resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = false
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_exec.name
      }
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-cluster"
    }
  )
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

locals {
  container_environment = [
    {
      name  = "NODE_ENV"
      value = var.node_env
    },
    {
      name  = "DB_SSL"
      value = var.db_ssl
    }
  ]

  container_secrets = var.enable_db_secret_access ? [
    {
      name      = "DB_HOST"
      valueFrom = "${var.db_secret_arn}:host::"
    },
    {
      name      = "DB_PORT"
      valueFrom = "${var.db_secret_arn}:port::"
    },
    {
      name      = "DB_NAME"
      valueFrom = "${var.db_secret_arn}:dbname::"
    },
    {
      name      = "DB_USER"
      valueFrom = "${var.db_secret_arn}:username::"
    },
    {
      name      = "DB_PASSWORD"
      valueFrom = "${var.db_secret_arn}:password::"
    }
  ] : []
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${var.project_name}-${var.environment}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-task-execution-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "task_execution_role_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "task_execution_secret_access" {
  count = var.enable_db_secret_access ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.db_secret_arn]
  }

  dynamic "statement" {
    for_each = var.secrets_kms_key_arn != "" ? [var.secrets_kms_key_arn] : []
    content {
      effect    = "Allow"
      actions   = ["kms:Decrypt"]
      resources = [statement.value]
    }
  }
}

resource "aws_iam_role_policy" "task_execution_secret_access" {
  count  = var.enable_db_secret_access ? 1 : 0
  name   = "${var.project_name}-${var.environment}-ecs-secrets-access"
  role   = aws_iam_role.task_execution_role.name
  policy = data.aws_iam_policy_document.task_execution_secret_access[0].json
}

resource "aws_iam_role" "task_role" {
  name               = "${var.project_name}-${var.environment}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-task-role"
    }
  )
}

data "aws_iam_policy_document" "task_role_exec" {
  statement {
    sid    = "SSMMessagesAccess"
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "CloudWatchLogsDescribe"
    effect    = "Allow"
    actions   = ["logs:DescribeLogGroups"]
    resources = ["*"]
  }

  statement {
    sid    = "CloudWatchLogsExecWrite"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.ecs_exec.arn,
      "${aws_cloudwatch_log_group.ecs_exec.arn}:log-stream:*",
    ]
  }
}

resource "aws_iam_role_policy" "task_role_exec" {
  name   = "${var.project_name}-${var.environment}-ecs-exec"
  role   = aws_iam_role.task_role.name
  policy = data.aws_iam_policy_document.task_role_exec.json
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.project_name}-${var.environment}-${var.container_name}"
  retention_in_days = var.log_retention_in_days

  tags = merge(
    var.common_tags,
    {
      Name = "/ecs/${var.project_name}-${var.environment}-${var.container_name}"
    }
  )
}

resource "aws_cloudwatch_log_group" "ecs_exec" {
  name              = "/ecs/exec/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_in_days

  tags = merge(
    var.common_tags,
    {
      Name = "/ecs/exec/${var.project_name}-${var.environment}"
    }
  )
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_name}-${var.environment}-${var.container_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    merge(
      {
        name        = var.container_name
        image       = "${var.ecr_repository_url}:${var.image_tag}"
        essential   = true
        environment = local.container_environment

        portMappings = [
          {
            containerPort = var.container_port
            hostPort      = var.container_port
            protocol      = "tcp"
          }
        ]

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = aws_cloudwatch_log_group.this.name
            "awslogs-region"        = var.region
            "awslogs-stream-prefix" = "ecs"
          }
        }
      },
      length(local.container_secrets) > 0 ? {
        secrets = local.container_secrets
      } : {}
    )
  ])

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-${var.container_name}"
    }
  )
}


resource "aws_ecs_service" "this" {
  name                   = "${var.project_name}-${var.environment}-service"
  cluster                = aws_ecs_cluster.this.id
  task_definition        = aws_ecs_task_definition.this.arn
  desired_count          = var.desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-service"
    }
  )
}
