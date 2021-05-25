{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeTasks",
        "ecs:ListContainerInstances",
        "ecs:RunTask",
        "ecs:StopTask",
        "iam:PassRole",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:ecs:eu-west-2:${account_id}:cluster/jenkins-prod-mgmt",
        "arn:aws:ecs:eu-west-2:${account_id}:task/*",
        "arn:aws:ecs:eu-west-2:${account_id}:task-definition/*:*",
        "arn:aws:iam::${account_id}:role/TDRCustodianAssumeRoleProd",
        "arn:aws:iam::${account_id}:role/TDRCustodianAssumeRoleStaging",
        "arn:aws:iam::${account_id}:role/TDRJenkinsAppExecutionRoleMgmt",
        "arn:aws:iam::${account_id}:role/TDRJenkinsAppTaskRoleMgmt",
        "arn:aws:iam::${account_id}:role/TDRJenkinsBuildAwsExecutionRole",
        "arn:aws:iam::${account_id}:role/TDRJenkinsBuildNpmExecutionRole",
        "arn:aws:iam::${account_id}:role/TDRJenkinsBuildPluginUpdatesExecutionRole",
        "arn:aws:iam::${account_id}:role/TDRJenkinsBuildPostgresExecutionRole",
        "arn:aws:iam::${account_id}:role/TDRJenkinsBuildTerraformExecutionRole",
        "arn:aws:iam::${account_id}:role/TDRJenkinsBuildTransferFrontendExecutionRole",
        "arn:aws:iam::${account_id}:role/TDRJenkinsCheckAmiRole",
        "arn:aws:iam::${account_id}:role/TDRJenkinsNodeLambdaRoleMgmt",
        "arn:aws:iam::${account_id}:role/TDRJenkinsNodeLambdaRoleProd",
        "arn:aws:iam::${account_id}:role/TDRJenkinsNodeLambdaRoleStaging",
        "arn:aws:iam::${account_id}:role/TDRJenkinsNodeReadParamsRoleProd",
        "arn:aws:iam::${account_id}:role/TDRJenkinsNodeReadParamsRoleStaging",
        "arn:aws:iam::${account_id}:role/TDRJenkinsNodeRoleProd",
        "arn:aws:iam::${account_id}:role/TDRJenkinsNodeRoleStaging",
        "arn:aws:iam::${account_id}:role/TDRJenkinsNodeS3ExportRoleStaging",
        "arn:aws:iam::${account_id}:role/TDRJenkinsPublishRole",
        "arn:aws:iam::${account_id}:role/TDRJenkinsRunSsmRoleProd",
        "arn:aws:iam::${account_id}:role/TDRJenkinsRunSsmRoleStaging",
        "arn:aws:iam::${account_id}:role/TDRScriptsTerraformRoleProd",
        "arn:aws:iam::${account_id}:role/TDRScriptsTerraformRoleStaging",
        "arn:aws:iam::${account_id}:role/TDRTerraformAssumeRoleProd",
        "arn:aws:iam::${account_id}:role/TDRTerraformAssumeRoleStaging",
        "arn:aws:iam::${account_id}:role/TDRTerraformRoleMgmt",
        "arn:aws:s3:::tdr-releases-mgmt",
        "arn:aws:s3:::tdr-releases-mgmt/*",
        "arn:aws:s3:::tdr-staging-mgmt",
        "arn:aws:s3:::tdr-staging-mgmt/*"
      ]
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "ecs:DeregisterTaskDefinition",
        "ecs:DescribeContainerInstances",
        "ecs:DescribeTaskDefinition",
        "ecs:ListClusters",
        "ecs:ListTaskDefinitions",
        "ecs:RegisterTaskDefinition",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
