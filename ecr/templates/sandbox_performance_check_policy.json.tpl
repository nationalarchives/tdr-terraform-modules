{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPull",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${management_account}:root",
          "arn:aws:iam::${sandbox_account}:root"
        ]
      },
      "Action": "ecr:*"
    }
  ]
}
