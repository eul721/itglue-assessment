data "template_file" "task-definition" {
    template = "${file("${path.module}/templates/ecs-task-definition.tpl")}"
    vars = {
        image_location = aws_ecr_repository.ecr-repo.repository_url
        s3_bucket_location = aws_s3_bucket.dest-bucket.id
    }
}
resource "local_file" "templated_task_definition" {
    content = data.template_file.task-definition.rendered
    filename = "${path.module}/out/ecs-task-definition.json"
}