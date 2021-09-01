{
  "Sid": "Allow_CloudWatch_for_CMK",
  "Effect": "Allow",
  "Principal": {
    "Service":[
      "cloudwatch.amazonaws.com"
    ]
  },
  "Action": [
    "kms:Decrypt","kms:GenerateDataKey*"
  ],
  "Resource": "*"
}