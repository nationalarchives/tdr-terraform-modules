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
      "Resource": "${kms_arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage"
      ],
      "Resource": [
        "${transform_engine_queue}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource" : [
        "arn:aws:s3:::tdr-consignment-export-${environment}"
        "arn:aws:s3:::tdr-consignment-export-judgment-${environment}"
      ]
    }
  ]
}
