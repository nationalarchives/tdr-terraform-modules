{
  "Version": "2012-10-17",
  "Id": "transform_engine_retry",
  "Statement": [
    {
      "Sid": "default_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SQS:GetQueueAttributes",
        "SQS:GetQueueUrl",
        "SQS:ListDeadLetterSourceQueues",
        "SQS:ReceiveMessage",
        "SQS:SendMessage"
      ],
      "Resource": "arn:aws:sqs:${region}:${account_id}:${sqs_name}"
    },
    {
      "Sid": "transform_engine_permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${transform_engine_role}"
        ]
      },
      "Action": "SQS:SendMessage",
      "Resource": "arn:aws:sqs:${region}:${account_id}:${sqs_name}"
    }
  ]
}