{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "states:SendTaskFailure",
        "states:SendTaskHeartbeat",
        "states:SendTaskSuccess"
      ],
      "Resource": [
        "arn:aws:states:${aws_region}:${account}:stateMachine:TDRConsignmentExport${titleEnvironment}"
      ],
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "${account_id}"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:ClientWrite"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "${account_id}"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::tdr-upload-files-${environment}/*",
        "arn:aws:s3:::tdr-upload-files-${environment}"
      ],
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "${account_id}"
        }
      }
    },
    {
      "Sid": "KMSs3ExportBucketPermission",
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "${account_id}"
        }
      },
      "Resource": ${kms_bucket_key_arns}
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::tdr-consignment-export-${environment}/*",
        "arn:aws:s3:::tdr-consignment-export-${environment}",
        "arn:aws:s3:::tdr-consignment-export-judgment-${environment}/*",
        "arn:aws:s3:::tdr-consignment-export-judgment-${environment}"
      ],
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "${account_id}"
        }
      }
    }
  ]
}

