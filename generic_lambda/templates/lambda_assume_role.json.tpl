{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${account_id}"
        }
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
