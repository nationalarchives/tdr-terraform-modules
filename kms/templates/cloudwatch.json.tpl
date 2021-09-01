{
  "Version": "2012-10-17",
  "Id": "cloudwatch-for-cmk",
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
      "Sid": "Allow_CloudWatch_for_CMK",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "cloudwatch.amazonaws.com"
        ]
      },
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey*"
      ],
      "Resource": "*"
    }
  ]
}
