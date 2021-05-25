{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "ssm:GetParameter",
      "Resource": [
        "arn:aws:s3:::tdr-jenkins-backup-mgmt",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/access_key",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/ami_aws_account",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/docker/password",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/docker/username",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/fargate_security_group",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/fargate_subnet",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/github/client",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/github/jenkins-api-key",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/github/jenkins-ssh-key",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/github/jenkins-ssh-username",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/github/prod/client",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/github/prod/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/github/secret",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/identitypoolid_intg",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/identitypoolid_prod",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/identitypoolid_staging",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/intg_account",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/jenkins_cluster_arn",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/jenkins_master_url",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/jenkins_url",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/management_account",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/npm_token",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/pr_monitor/slack/webhook",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/prod_account",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/secret_key",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/slack/token",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/sonatype/passphrase",
        "arn:aws:ssm:eu-west-2:${account_id}:parameter/mgmt/staging_account"
      ]
    },
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
        "arn:aws:ecr:eu-west-2:${account_id}:repository/auth-server",
        "arn:aws:ecr:eu-west-2:${account_id}:repository/consignment-api",
        "arn:aws:ecr:eu-west-2:${account_id}:repository/consignment-export",
        "arn:aws:ecr:eu-west-2:${account_id}:repository/file-format-build",
        "arn:aws:ecr:eu-west-2:${account_id}:repository/transfer-frontend",
        "arn:aws:ecr:eu-west-2:${account_id}:repository/yara",
        "arn:aws:ecr:eu-west-2:${account_id}:repository/yara-dependencies",
        "arn:aws:ecr:eu-west-2:${account_id}:repository/yara-rules"
      ]
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "ecr:GetAuthorizationToken",
      "Resource": "*"
    }
  ]
}
