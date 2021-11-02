{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ],
      "Resource": [
        "${cloudwatch_log_group}",
        "${cloudwatch_log_group}:log-stream:*",
        "arn:aws:ecr:eu-west-2:${ecr_account_number}:repository/auth-server"
      ]
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource" : "*"
    }
  ]
}
