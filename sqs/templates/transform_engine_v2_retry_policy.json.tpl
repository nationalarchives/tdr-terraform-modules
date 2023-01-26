{
  "Version": "2012-10-17",
  "Id": "transform_engine_v2_policy",
  "Statement": [
    {
      "Sid": "transform_engine_v2_policy",
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
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:${region}:${account_id}:${sqs_name}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": ${jsonencode(topic_arns)}
        }
      }
    }
  ]
}
