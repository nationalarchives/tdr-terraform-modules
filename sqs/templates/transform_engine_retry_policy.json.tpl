{
  "Version": "2012-10-17",
  "Id": "transform_engine_retry",
  "Statement": [
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
