resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.project-name}-ecs-cluster"
  tags = local.common_aws_tags
}

resource "aws_ecr_repository" "ecr-repo" {
  name = "${var.project-name}-ecr-repo"
}

data "aws_iam_policy_document" "ecr-repo-policy" {
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
    ]
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    effect = "Allow"
  }
}

resource "aws_ecr_repository_policy" "ecr-repo-policy" {
  repository = aws_ecr_repository.ecr-repo.name
  policy = data.aws_iam_policy_document.ecr-repo-policy.json
}

resource "aws_ecs_task_definition" "ecs-task-definition" {
  family = "${var.project-name}-tf"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn = aws_iam_role.s3-interact-role.arn
  execution_role_arn = aws_iam_role.ecs-task-execution-role.arn
  cpu = 256
  memory = 512
  container_definitions = data.template_file.task-definition.rendered
}

resource "aws_ecs_service" "app-ecs-service" {
  depends_on = [
    aws_iam_role.s3-interact-role,
    aws_ecs_task_definition.ecs-task-definition,
    aws_lb.public-to-ecs-alb,
    aws_lb_listener.public-to-ecs-alb-app-tg
    ]
  name = "${var.project-name}"
  cluster = aws_ecs_cluster.ecs-cluster.id
  launch_type = "FARGATE"
  task_definition = "${aws_ecs_task_definition.ecs-task-definition.arn}"
  desired_count = 3

  network_configuration {
    subnets = local.private_subnets.*.id
    security_groups = [aws_security_group.private-sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app-tg.arn
    container_name = "app"
    container_port = 8080
  }
}