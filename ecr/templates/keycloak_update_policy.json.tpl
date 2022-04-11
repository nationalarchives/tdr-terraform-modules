{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AllowPull",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${intg_account}:role/TDRKeycloakUpdateECSExecutionRoleIntg",
          "arn:aws:iam::${staging_account}:role/TDRKeycloakUpdateECSExecutionRoleStaging",
          "arn:aws:iam::${prod_account}:role/TDRKeycloakUpdateECSExecutionRoleProd"
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
