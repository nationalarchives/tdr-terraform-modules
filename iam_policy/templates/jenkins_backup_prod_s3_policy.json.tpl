{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::tdr-jenkins-backup-prod-mgmt",
        "arn:aws:s3:::tdr-jenkins-backup-prod-mgmt/*"
      ]
    }
  ]
}
