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
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-reporting-${environment}",
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-reporting-${environment}:log-stream:*"
      ],
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "${account_id}"
        }
      }
    },
    {
      "Sid": "DecryptEnvVar",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": "${kms_arn}",
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "${account_id}"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces"
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
        "ssm:GetParameter"
      ],
      "Resource": "arn:aws:ssm:eu-west-2:${account_id}:parameter${parameter_name}",
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "${account_id}"
        }
      }
    }
  ]
}
