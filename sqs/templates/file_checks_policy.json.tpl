{
  "Version": "2012-10-17",
  "Id": "file_checks_policy",
  "Statement": [
    {
      "Sid": "statement_for_file_check_queues",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${account_id}:role/TDRDownloadFilesRole"
      },
      "Action": [
        "SQS:SendMessage"
      ],
      "Resource": "arn:aws:sqs:${region}:${account_id}:${sqs_name}"
    }
  ]
}
