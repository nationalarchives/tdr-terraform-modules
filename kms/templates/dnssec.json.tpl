{
  "Version": "2012-10-17",
  "Id": "Key policy created by Terraform",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow Route 53 DNSSEC Service",
      "Action": [
        "kms:DescribeKey",
        "kms:GetPublicKey",
        "kms:Sign"
      ],
      "Effect": "Allow",
      "Principal": {
        "Service": "dnssec-route53.amazonaws.com"
      },
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${account_id}"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:route53:::hostedzone/*"
        }
      }
    },
    {
      "Sid": "Allow Route 53 DNSSEC Service to CreateGrant",
      "Action": "kms:CreateGrant",
      "Effect": "Allow",
      "Principal": {
        "Service": "dnssec-route53.amazonaws.com"
      },
      "Resource": "*",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    }
  ]
}
