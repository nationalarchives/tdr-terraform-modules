{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid":"AllowPublishToDaEventBus",
      "Effect":"Allow",
      "Action":"sns:Publish",
      "Resource": "${da_event_bus_arn}"
    },
    {
      "Sid": "AllowAccessToDaEventBusKmsKey",
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "${da_event_bus_kms_key_arn}"
    }
  ]
}
