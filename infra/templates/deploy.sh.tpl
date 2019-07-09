#!/usr/bin/env bash
docker build -t ${repo_location}:latest .
docker push ${repo_location}
aws ecs update-service --cluster ${cluster_name} --service ${service_name} --force-new-deployment