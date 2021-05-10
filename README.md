# aws-deployment-guide
Seamlessly deploy cryoSPARC in the cloud using AWS.

[See the Deployment Guide for full deployment instructions.](https://guide.cryosparc.com/deploy/cryosparc-on-aws)

The Deployment Guide provides end-to-end sample instructions for deployment [cryoSPARC](https://cryosparc.com/) on AWS using AWS ParallelCluster. 
CryoSPARC is developed by Structura Biotechnology Inc. Additional information about cryoSPARC, including [licensing](https://guide.cryosparc.com/licensing), is available at [guide.cryosparc.com](https://guide.cryosparc.com/).

## Note
The Deployment Guide and these scripts serve as an example of possible installation options, performance and cost, but each user’s results may vary. Performance and costs may scale differently depending on the specific compute setup, data being processed, how long AWS compute resources are being used, specific steps used in processing, etc. 

## Usage
```
./deploy-cryosparc_v1.sh --region your-aws-region \
--cluster-name cryosparc \
--az <your-availability-zone> \
--data-bucket cryosparc-test-data-np \
--aws-key key-cryoSPARC \
--cryosparc-license-id <your-cryosparc-license>
```
`region` Region in which to deploy the cluster (e.g., `us-east-1`)

`cluster-name` Name of the cluster for identification purposes

`az` AZ in which to deploy the cluster. Make sure that instance is available in the specified AZ. (e.g., `us-east-1a`)

`data-bucket` Name of the S3 bucket that contains all raw data. This will be linked to the EC2 instance with Amazon FSx for Lustre. All movies will be uploaded here. 

`aws-key` Name (not the path) of the SSH key pair created for the EC2 instances

`cryosparc-license-id` The license ID provided by Structura Bio for your cryoSPARC instance

## Permissions
During testing, the following AWS managed policies were attached to the IAM user that executed `deploy-cryosparc_v1.sh`:

- AmazonEC2FullAccess
- AmazonFSxFullAccess
- AmazonS3FullAccess
- AmazonDynamoDBFullAccess
- CloudWatchLogsFullAccess
- AmazonRoute53FullAccess
- AWSCloudFormationFullAccess
- AWSLambda_FullAccess


as well as the following custom managed policy:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CustomIAMCryoSPARCPolicy",
            "Effect": "Allow",
            "Action": [
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:GetRole",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:AttachRolePolicy",
                "iam:PutRolePolicy",
                "iam:AddRoleToInstanceProfile",
                "iam:PassRole",
                "iam:DetachRolePolicy",
                "iam:DeleteRolePolicy",
                "iam:GetRolePolicy"
            ],
            "Resource": "*"
        }
    ]
}
```
[See this article for more details on creating custom IAM policies.](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_create-console.html)
