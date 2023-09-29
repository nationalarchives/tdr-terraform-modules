{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage"
      ],
      "Resource": [
        "${transform_engine_output_queue_arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ChangeMessageVisibility",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ReceiveMessage",
        "sqs:SendMessage"
      ],
      "Resource": [
        "${transform_engine_retry_queue_arn}",
        "${transform_engine_v2_out_queue_arn}"
      ]
    },
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
        "kms:GenerateDataKey",
        "kms:DescribeKey"
      ],
      "Resource": "${da_event_bus_kms_key_arn}"
    }
  ]
}
