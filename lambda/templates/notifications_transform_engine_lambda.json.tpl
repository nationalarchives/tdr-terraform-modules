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
        "${transform_engine_retry_queue_arn}"
      ]
    },
    {
      "Sid":"AllowPublishToTreIn",
      "Effect":"Allow",
      "Action":"sns:Publish",
      "Resource": "${transform_engine_in_topic_arn}"
    },
    {
      "Sid": "AllowAccessToTreKmsKey",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey*"
      ],
      "Resource": "${transform_engine_kms_key_arn}"
    }
  ]
}
