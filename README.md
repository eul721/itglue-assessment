# itglue-assessment

# Prerequisites

* [Terraform 0.12](https://www.terraform.io/downloads.html)
* [Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/) (needed to build the app container)
* [aws-cli](https://aws.amazon.com/cli/) (for new deployments of app)
* [terminal with AWS Admin Access credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) (**Important**)
* One functional VPC in your AWS account. 

# Instructions

1. In the `/infra` folder, run `terraform init`. This will initialize the folder with a terraform state.
2. In the same folder, run 
    ```
    terraform apply -var 'vpc-id=<vpc_id>'
    ```
    where <vpc_id> is the id of your VPC w/o brackets. When prompted, type yes. There should be **34** resource additions.
    > Terminal should now show whether the stack creation has succeeded.
3. Outputs will contain the results/resources from stack creation. In the outputs, find this line:
    ```
    lb_dns = <endpoint to app>
    ```
    Copy the value of that key and paste it in the browser. You will be directed to the app.

    (For the sake of the assessment, deployment is simplified to one single deployment script. This **deploy script** is automatically generated with the correct repository name and ecs cluster/service name in `/app/deploy-script.sh`)
4. Test the app and verify it works. At first, it may still show `503 Service Unavailable` because the tasks still needed to be registered as targets on the load balancer. **Give this 2 minutes.**
5. To make updates, navigate to `/app` folder. Make appropriate changes to `app.js` or `Dockerfile`, then execute `deploy-script.sh`. It will take up to 2 minutes for the live app to reflect those changes.

# Cleanup

To cleanup the app & stack, you will need to first empty the bucket. Use this command
```
aws s3 rm s3://<bucket-name> --recursive
```

bucket-name is provided in the outputs of the stack ran earlier.

This file is NOT run automatically as part of the stack. This is to simulate importance of S3 objects and preventing them from getting deleted.

Then, you can clean-up the stack. In `/infra` folder, execute 
```
terraform destroy -var 'vpc-id=<vpc_id>'
```
where <vpc_id> is the id of your VPC w/o brackets. This can take some time. 