{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${account_id}",
          "aws:SourceArn": "arn:${aws_partition}:cloudtrail:${aws_region}:${account_id}:trail/${trail_name}"
        }
      }
    }
  ]
}
