{
  "Version": "2012-10-17",
  "Id": "secure-transport-tdr-backend-code-mgmt",
  "Statement": [
    %{ for grant in canonical_user_grants ~}
    {
      "Sid": "GrantPermissions-${grant.id}",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${grant.id}"
      },
      "Action": ${jsonencode(grant.permissions)},
      "Resource": [
        "arn:aws:s3:::${bucket_name}",
        "arn:aws:s3:::${bucket_name}/*"
      ]
    },
    %{ endfor ~}
    {
      "Sid": "AllowSSLRequestsOnly",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::tdr-backend-code-mgmt",
        "arn:aws:s3:::tdr-backend-code-mgmt/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${external_account_1}:role/TDRGithubActionsDeployLambdaIntg",
          "arn:aws:iam::${external_account_2}:role/TDRGithubActionsDeployLambdaStaging",
          "arn:aws:iam::${external_account_3}:role/TDRGithubActionsDeployLambdaProd"
        ]
      },
      "Action": ["s3:GetObject"],
      "Resource": [
        "arn:aws:s3:::tdr-backend-code-mgmt/*"
      ]
    }
  ]
}
