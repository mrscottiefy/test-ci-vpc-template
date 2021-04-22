```
       __           __   _            _________________
      / /__  ____  / /__(_)___  _____/ ____/ ____/ ___/
 __  / / _ \/ __ \/ //_/ / __ \/ ___/ __/ / /    \__ \ 
/ /_/ /  __/ / / / ,< / / / / (__  ) /___/ /___ ___/ / 
\____/\___/_/ /_/_/|_/_/_/ /_/____/_____/\____//____/  
                                                       
```

# Jenkins on Elastic Container Service
Jenkins is an open-source continuous integration/deployment tool. We run Jenkins on ECS-Fargate so that Jenkins slaves only spin up when needed, giving us more cost savings when we aren't building anything. This has several trade-offs like having to wait for Jenkins master to spawn a slave in ECS.

# Terraform
Terraform is a Infrastructure as Code tool used to provision resources in the cloud.

# CI Blueprint
This repository serves as a blueprint for any onboarding CI server into HDBDevNet.
The network diagram can be found [here](https://confluence.devnet.gccaws.hdb.gov.sg/display/HDBDEVNET/CI+Network+Diagram). This also serves as a starting point for project to start using a CI workflow.

# Terraform files
```
.
├── file-system.tf
├── jenkins-main.json
├── load-balancers.tf
├── main.tf
├── output.tf
├── README.md
├── reverse-proxy.tf
├── security-groups.tf
├── subnets.tf
├── user-data.sh
└── vpc-endpoints.tf
```
Each of the file contains what exactly the file name states, e.g. reverse-proxy.tf provisions the 2 EC2 instances shown in the diagram in the protected subnet. Only exception is main.tf where it provisions the actual ECS cluster, a CloudWatch log group, and the CloudMap for Route53 for service discovery. These files are compatible with Terraform v0.14.8.

# Dockerfile

The Dockerfile included in this repository is to be built and uploaded into an image repository. Plugins.txt contains all the plugins and version for Jenkins to install before the image is built. More information can be found in these files.

# Using the terraform files

## Prerequisites
Before applying the terraform, we have a few prerequisites. 
1. Your GCC AWS account
2. Jenkins image in your ECR
## Steps
1. AWS configuration
2. VPC configuration
3. Applying terraform
4. Using Jenkins
   
## AWS configuration
At the top of main.tf, we'll have a few configurations to make before applying the terraform.
```
provider "aws" {
  profile = "dev-aws"
  region  = "ap-southeast-1"
}
```
Make sure your profile under the provider section is valid. You should have your access key and secret access key for your own AWS account configured on the machine that is applying the terraform files. The keys can be taken from your GCC AWS account under IAM.

Also under IAM, make sure you have "ecsTaskExecutionRole" role in your account. If its not present, create a new role.

If your account does not already have a task execution role, use the following steps to create the role.

### To create the ecsTaskExecutionRole IAM role

1. Open the IAM console at https://console.aws.amazon.com/iam/.
2. In the navigation pane, choose Roles, Create role.
3. In the Select type of trusted entity section, choose "Elastic Container Service".
4. For Select your use case, choose "Elastic Container Service Task", then choose Next: Permissions.
5. In the Attach permissions policy section, search for "AmazonECSTaskExecutionRolePolicy", select the policy, and then choose Next: Review.
6. For Role Name, type "ecsTaskExecutionRole" and choose Create role.

You will need this role in the later step.

## VPC configuration
```
locals {
  vpc_id                   = "vpc-0c7869fb70b78e2f9"
  vpc_default_sg           = "sg-0d6b0299f873840bc"
  ecs_execution_role       = "arn:aws:iam::896013561597:role/ecsTaskExecutionRole"
  ecs_task_role            = "arn:aws:iam::896013561597:role/ecsTaskExecutionRole"
  public_subnet_az_a_cidr  = "10.1.2.64/28"
  public_subnet_az_b_cidr  = "10.1.2.80/28"
  private_subnet_az_a_cidr = "10.1.2.0/27"
  private_subnet_az_b_cidr = "10.1.2.32/27"
  route_table_id           = "rtb-0c8d1c4ab39b5fff5"
}
```
All values in this "locals" object needs to be changed. Most of these can be found in your GCC AWS account dashboard, e.g. vpc_id, vpc_default_sg, route_table_id.

| name                     | value                                                             |
| ------------------------ | ----------------------------------------------------------------- |
| vpc_id                   | Your VPC ID                                                       |
| vpc_default_sg           | Your VPC default Security Group                                   |
| ecs_execution_role       | Execution role arn for your ECS                                   |
| ecs_task_role            | Task execution role arn for your ECS tasks                        |
| public_subnet_az_a_cidr  | CIDR for your protected subnet in AZ-A (top left)                 |
| public_subnet_az_b_cidr  | CIDR for your protected subnet in AZ-B (top right)                |
| private_subnet_az_a_cidr | CIDR for your private subnet in AZ-A (botton left)                |
| private_subnet_az_b_cidr | CIDR for your private subnet in AZ-B (botton right)               |
| route_table_id           | Route table ID for S3 VPC Endpoint Gateway to insert records into |

## Applying terraform

Once the changes are completed, you are now ready to apply the terraform files.

```
terraform apply
```
If it runs successfully, you should see a similar output of the following

```
Apply complete! Resources: 38 added, 0 changed, 0 destroyed.

Outputs:

jenkins_alb_public_dns = "http://jenkins-external-alb-10821408.ap-southeast-1.elb.amazonaws.com"
```
The URL you see there is the endpoint of which Jenkins is running at. You should be able to access it once the ECS service is up and running.

# Using Jenkins

You are able to get the unlock password for Jenkins in the logs of your running ECS task.

## Jenkins through a proxy

We have a central NAT and egress for the HDBDevNet. We have to configure Jenkins to use this proxy for our plugin updates/communicating with AWS.

1. Manage Jenkins
2. Manage Plugins
3. Advanced tab 
4. Under HTTP Proxy Configuration

| Server                                                              | Port |
| ------------------------------------------------------------------- | ---- |
| devnet-egress-nlb-298c598daa158cb6.elb.ap-southeast-1.amazonaws.com | 80   |

Jenkins is now configured to use the HDBDevNet central egress.

## Configuring Jenkins agents

This is where you configure Jenkins to spawn agents in ECS whenever a job is tasked to.

1. Manage Jenkins
2. Manage Nodes and Clouds
3. Configure Clouds

Add in your AWS keys

| Name              | Value                    |
| ----------------- | ------------------------ |
| Kind              | AWS Credentials          |
| ID                | Identifier for your keys |
| Access Key ID     | aws_access_key_id        |
| Secret Access Key | aws_secret_access_key    |

Click Advanced...
Then fill in the form as per the table below

| Name                   | Value                 |
| ---------------------- | --------------------- |
| Name                   | ecs-cloud             |
| Amazon ECS Region Name | ap-southeast-1        |
| ECS Cluster            | .../jenkins-ecs-slave |

## ECS agent templates

| Name                    | Value                                               | Remarks                                   |
| ----------------------- | --------------------------------------------------- | ----------------------------------------- |
| Label                   | ecs                                                 | To identify this cloud agent              |
| Template Name           | ecs                                                 |                                           |
| Docker Image            | jenkins/inbound-agent                               | Docker image to run when agent is spawned |
| Launch type             | FARGATE                                             |                                           |
| Network mode            | awsvpc                                              |                                           |
| Filesystem root         | /home/jenkins                                       |                                           |
| Platform Version        | LATEST                                              |                                           |
| Hard Memory Reservation | 2048                                                |                                           |
| CPU units               | 1024                                                |                                           |
| Subnets                 | subnet-050c97fb128478cf7, subnet-0c86396d699e74b1b  | Insert your own private subnet IDs        |
| Security Groups         | sg-06cc03918f6c74989                                | Insert your own jenkins-ecs-sg ID         |
| Task Role ARN           | arn:aws:iam::896013561597:role/ecsTaskExecutionRole | Insert your own ecsTaskExecutionRole arn  |
| Task Execution Role ARN | arn:aws:iam::896013561597:role/ecsTaskExecutionRole | Insert your own ecsTaskExecutionRole arn  |
| Logging Driver          | awslogs                                             |                                           |

Logging Configuration as follows

| Name                  | Value             |
| --------------------- | ----------------- |
| awslogs-group         | jenkins-ecs-slave |
| awslogs-region        | ap-southeast-1    |
| awslogs-stream-prefix | jenkins-ecs-slave |

Add an additional environment variable to the container to use websockets instead of custom TCP port for agent communication

| Name              | Value |
| ----------------- | ----- |
| JENKINS_WEBSOCKET | true  |

Click save.
Your ECS cloud is now configured. To spawn agents in this cluster, try running a pipeline job indicating agent as 'ecs'.

# To Do
1. TLS for the load balancers