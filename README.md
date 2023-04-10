
# Dataflow solution 

The organization is currently working on a data lake project and needs a solution to enable
these agencies to securely upload data to their Amazon S3 buckets. However, these agencies
are not very tech-savvy and have requested an SFTP connection for daily or weekly uploads.

We will outline a solution that utilizes AWS Transfer Family to create an
SFTP server that enables the agencies to securely transfer their data to the S3 buckets. We
will also provide step-by-step instructions for implementing this solution, as well as best
practices to ensure secure and efficient file transfer and the solution will be provisioned in the form of Terraform scripts.




## Architecture

![architecture diagram](https://github.com/creazer-I/dataflow-assignment-iac/blob/main/dataflow-architecture-diagram.png)




## Overview

1. AWS Transfer Family is a managed service for file transfer to/from Amazon S3.

2. Organization provides agencies with username, hostname, and SSH key to log in.

3. Agencies can use FTP tools like FileZilla and WinSCP to connect to the server.

4. Once connected, agencies can securely transfer files to and from Amazon S3.

5. IAM role is assigned for each of the agencies while creating their access.

6. Role will restrict agencies from uploading any other than required file extension i.e.,
csv, excel and Json.

7. S3 bucket has been encrypted with AWS KMS which will restrict access to all other
services except the agencies.

8. EventBridge triggers a Lambda function based on a specified schedule.

9. The Lambda function checks for missed file uploads by agencies for the current day.

10. If any missed file uploads are found, the Lambda function uses SNS to send an email
to the SRE team, notifying them of the issue
## Pre-req

    1. Install terraform
    2. An AWS Account


# Structure
```
|
sftp-data-flow-terrafrom\
|_ _ dev\
    |_ _#terraform script files
```



# Installations

Go to the working directory

Open CMD

1. Initialize terraform

```
terrafrom init
```
command for terraform to install modules and providers

2. Plan the resources

```
terrafrom plan
```
command to preview the changes that
will be made to your infrastructure.

3. Deploy the resources

```
terraform apply
```
command to deploy the services in the aws

#Security

1. s3 bucket will be encrypted by kms key

2. use [IAM Policy](https://github.com/creazer-I/dataflow-assignment-iac/blob/main/sftp-data-flow-terrafrom/iam-policy-least-privilege.json) whem creating user so terraform would deploy resources in a least privilege.
