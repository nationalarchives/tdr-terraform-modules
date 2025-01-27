{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:UpdateService",
        "kms:Decrypt",
        "kms:GenerateDataKey",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "sns:Publish",
        "ssm:GetParameter",
        "ssm:PutParameter"
      ],
      "Resource": [
        "arn:aws:ecs:eu-west-2:${account_id}:service/frontend_${environment}/frontend_service_${environment}",
        "arn:aws:ecs:eu-west-2:${account_id}:service/transferservice_${environment}/transferservice_service_${environment}",
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-rotate-keycloak-secrets-${environment}",
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-rotate-keycloak-secrets-${environment}:log-stream:*",
        "arn:aws:sns:eu-west-2:${account_id}:tdr-notifications-${environment}",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/backend_checks_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/realm_admin_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/reporting_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/rotate_secrets_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/rotate_secrets_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/user_admin_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/user_read_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/transfer_service_client/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/${environment}/keycloak/draft_metadata_client/secret",
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
    },
    {
      "Effect": "Allow",
      "Action": [
        "events:DescribeConnection",
        "events:UpdateConnection"
      ],
      "Resource": "arn:aws:events:eu-west-2:${account_id}:connection/${api_connection_name}"
    },
    {
      "Action": [
        "secretsmanager:*"
      ],
      "Effect": "Allow",
      "Resource": "${api_connection_secret_arn}"
    }
  ]
}
