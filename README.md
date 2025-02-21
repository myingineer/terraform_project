# CLOUD HOSTING ON AWS WITH TERRAFORM

## This file uses Terraform to host the Habit Tracker in this repository on AWS.
Based on the robustness of the Habit Tracker API, this cloud solution leverages different services like 

- **EC2**
    This being **Amazon Elastic Cloud Compute**, the main code is hosted here and across multiple AZs for availability
    The EC2 instance is the main services that calculates the logic of the application

- **VPC**
    This being **Amazon Virtual Private Cloud**, it gives me a space to host my own infrastructure in the cloud. Making my own solution
    isolated from the other solutions present in the same cloud

- **ALB**
    This being **Amazon Application Load Balance**, it allows our application to be able to properly distribute traffic preventing
    the application from handling all the traffic from just one ec2 instance

- **RDS**
    This being **Amazon Relational Database System**, it allows us to have our storage system on the cloud for storage based operations
    from the **EC2** instance.

- **WAF**
    This being **Amazon Web Application Firewall**, it helps check for **DDOS** or **SQL Injection** attacks from the traffic before it
    reaches the **ALB** to help secure our solution from common web attacks

- **SG**
    This being **Amazon Security Group**, this helps us make rules as to where we want to allow traffic from and where we do not want to allow traffic from

- **Cloud Watch**
    This being **Amazon Cloud Watch**, helps us monitor our application and also send logs. When there is an issue with our application,
    we are notified immediately due to this service. This makes it possible for the app to contantly log issues for faster debugging

# Note 
Many other services being used but not mentioned in this README, are also key integral part as to what makes this application run.
We make use of **GITHUB ACTIONS** to try to host the code, though it has being disabled.

# HOW TO RUN

## LOCALLLY
1. **Clone the Repository**
    git clone https://github.com/myingineer/terraform_project
    cd into the project

2. **Initialize Terraform**
    run 
        terraform init

3. **AWS SECRETS and SECRETS ID**
    Add your `AWS_SECRET` and `AWS_SECRET_ID` as environment variables

4. **Terraform Plan**
    run
        terraform validate
    then
        terraform plan
    this ensures no issues or conflict

5. **Apply the Solution**
    run 
        terraform apply --auto-approve
    you would be prompted for a password for the database
    input a password and press `Enter`

6. **Destroy the Solution**
    run
        terraform destroy --auto-approve
    you would be prompted for a password for the database again
    input the previous password and press `Enter`