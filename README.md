# aws-deployment-guide
Seamlessly deploy cryoSPARC in the cloud using AWS
See the guide for full deployment instructions [LINK TBC].

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
