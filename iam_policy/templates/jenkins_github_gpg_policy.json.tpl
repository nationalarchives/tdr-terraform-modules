{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "ssm:GetParameters",
      "Resource": [
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/github/gpg/passphrase",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/github/gpg/key",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/github/gpg/id"
      ]
    }
  ]
}
