{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AllowPullConsignmentAPI",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${intg_account}:role/KeycloakECSExecutionRoleIntg",
          "arn:aws:iam::${staging_account}:role/KeycloakECSExecutionRoleStaging",
          "arn:aws:iam::${prod_account}:role/KeycloakECSExecutionRoleProd"
        ]
      },
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]
    }
  ]
}
