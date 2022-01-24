{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": [
        "arn:aws:s3:::tdr-antivirus-test-files-mgmt/*",
        "arn:aws:s3:::tdr-backend-code-mgmt/*"
      ]
    }
  ]
}
