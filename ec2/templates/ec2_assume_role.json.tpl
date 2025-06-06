{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${account_id}"
        }
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
