{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeImages",
        "ecr:DescribeRepositories",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:ListImages",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": [
        "arn:aws:ecr:eu-west-2:${account_id}:repository/jenkins",
        "arn:aws:ecr:eu-west-2:${account_id}:repository/jenkins-build-aws",
        "arn:aws:ecr:eu-west-2:${account_id}:repository/jenkins-build-npm",
        "arn:aws:ecr:eu-west-2:${account_id}:repository/jenkins-build-plugin-updates",
        "arn:aws:ecr:eu-west-2:${account_id}:repository/jenkins-build-postgres",
        "arn:aws:ecr:eu-west-2:${account_id}:repository/jenkins-build-terraform",
        "arn:aws:ecr:eu-west-2:${account_id}:repository/jenkins-build-transfer-frontend",
        "arn:aws:ecr:eu-west-2:${account_id}:repository/jenkins-prod",
        "arn:aws:ecr:eu-west-2:${sandbox_account_id}:repository/*"
      ]
    }
  ]
}
