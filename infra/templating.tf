data "template_file" "task-definition" {
    template = "${file("${path.module}/templates/ecs-task-definition.tpl")}"
    vars = {
        image_location = aws_ecr_repository.ecr-repo.repository_url
        s3_bucket_location = aws_s3_bucket.dest-bucket.id
    }
}
# resource "local_file" "templated_task_definition" {
#     content = data.template_file.task-definition.rendered
#     filename = "${path.module}/out/ecs-task-definition.json"
# }

data "template_file" "deploy-script" {
    template = file("${path.module}/templates/deploy.sh.tpl")
    vars = {
        repo_location = aws_ecr_repository.ecr-repo.repository_url
        cluster_name = aws_ecs_cluster.ecs-cluster.name
        service_name = aws_ecs_service.app-ecs-service.name
    }
}

resource "local_file" "deploy-script" {
    content = data.template_file.deploy-script.rendered
    filename = "${path.module}/../app/deploy-script.sh"

    provisioner "local-exec" { // Run deploy script after it's been created
        command = "${path.module}/../app/deploy-script.sh"
        working_dir = "${path.module}/../app"
    }
}