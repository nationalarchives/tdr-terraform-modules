{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-notifications-${environment}",
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-notifications-${environment}:log-stream:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "ses:SendEmail",
      "Resource": [
        "arn:aws:ses:eu-west-2:${account_id}:identity/${email}",
        "arn:aws:ses:eu-west-2:${account_id}:identity/tdr-management.nationalarchives.gov.uk"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "ecr:DescribeImageScanFindings",
      "Resource": [
        "arn:aws:ecr:eu-west-2:${account_id}:repository/*"
      ]
    },
    {
      "Sid": "DecryptEnvVar",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": [
        "${kms_account_arn}",
        "${kms_arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource" : [
        "arn:aws:s3:::tdr-consignment-export-${environment}",
        "arn:aws:s3:::tdr-consignment-export-${environment}/*",
        "arn:aws:s3:::tdr-consignment-export-judgment-${environment}",
        "arn:aws:s3:::tdr-consignment-export-judgment-${environment}/*"
      ]
    },
    {
      "Sid": "Allow TRE to use this KMS key",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${da_event_bus_kms_key_arn}"
        ]
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    }
  ]
}
