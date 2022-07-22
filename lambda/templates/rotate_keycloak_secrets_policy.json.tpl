{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ssm:PutParameter",
        "ecs:UpdateService",
        "ssm:GetParameter",
        "sns:Publish",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": [
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-rotate-keycloak-secrets-${environment}",
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-rotate-keycloak-secrets-${environment}:log-stream:*",
        "arn:aws:ecs:eu-west-2:${account_id}:service/frontend_${environment}/frontend_service_${environment}",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/backend_checks_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/realm_admin_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/reporting_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/rotate_secrets_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/user_admin_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/rotate_secrets_client/secret",
        "arn:aws:sns:eu-west-2:${account_id}:tdr-notifications-${environment}",
        "${kms_arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces"
      ],
      "Resource": "*"
    }
  ]
}
