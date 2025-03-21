{
  "Version": "2012-10-17",
  "Id": "key-default-1",
  "Statement": [
  %{ if aws_backup_service_role != "" }
    {
      "Sid": "AllowCopyToCentralBackupAccount",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_backup_service_role}"
    },
    "Action": [
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:Decrypt",
      "kms:CreateGrant"
    ],
    "Resource": "*"
    },
  %{ endif }
  %{ if aws_backup_local_role != "" }
    {
      "Sid": "AllowSourceBackupRoleAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_backup_local_role}"
    },
    "Action": [
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:Decrypt",
      "kms:CreateGrant"
    ],
    "Resource": "*",
    "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${account_id}"
        }
      }
    },
  %{ endif }
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
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "kms:EncryptionContext:aws:sqs:arn": [
            "arn:aws:sqs:eu-west-2:${account_id}:tdr-backend-check-failure-${environment}",
            "arn:aws:sqs:eu-west-2:${account_id}:tdr-download-files-${environment}"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "kms:EncryptionContext:aws:sns:topicArn": [
            "arn:aws:sns:eu-west-2:${account_id}:tdr-s3-dirty-upload-${environment}"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudwatch.amazonaws.com"
      },
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "Allow EventBridge access to the KMS key",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": "*"
    }
  ]
}
