{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::tdr-jenkins-backup-mgmt/*",
        "arn:aws:s3:::tdr-jenkins-backup-mgmt"
      ]
    }
  ]
}
