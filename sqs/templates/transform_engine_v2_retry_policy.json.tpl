{
  "Version": "2012-10-17",
  "Id": "transform_engine_v2_policy",
  "Statement": [
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
