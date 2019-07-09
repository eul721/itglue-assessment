[
  {
    "name": "app",
    "image": "${image_location}:latest",
    "essential": true,
    "environment": [
      {
        "name": "S3_BUCKET_LOCATION",
        "value": "${s3_bucket_location}"
      }
    ],
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080,
        "protocol": "tcp"
      }
    ]
  }
]