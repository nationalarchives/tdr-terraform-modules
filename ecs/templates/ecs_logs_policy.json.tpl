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
        "${log_group_arn}",
        "${log_group_arn}:log-stream:*"
      ]
    }
  ]
}