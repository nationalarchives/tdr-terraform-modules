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
        "arn:aws:ecs:eu-west-2:${account_id}:cluster/jenkins-mgmt",
        "arn:aws:ecs:eu-west-2:${account_id}:task/*",
        "arn:aws:ecs:eu-west-2:${account_id}:task-definition/*:*",
        "arn:aws:iam::${account_id}:role/TDRCustodianAssumeRoleIntg",
        "arn:aws:iam::${account_id}:role/TDRJenkinsAppExecutionRoleMgmt",
        "arn:aws:iam::${account_id}:role/TDRJenkinsAppTaskRoleMgmt",
        "arn:aws:iam::${account_id}:role/TDRJenkinsBuildAwsExecutionRole",
        "arn:aws:iam::${account_id}:role/TDRJenkinsBuildNpmExecutionRole",
        "arn:aws:iam::${account_id}:role/TDRJenkinsBuildPluginUpdatesExecutionRole",
        "arn:aws:iam::${account_id}:role/TDRJenkinsBuildPostgresExecutionRole",
        "arn:aws:iam::${account_id}:role/TDRJenkinsBuildTerraformExecutionRole",
        "arn:aws:iam::${account_id}:role/TDRJenkinsBuildTransferFrontendExecutionRole",
        "arn:aws:iam::${account_id}:role/TDRJenkinsCheckAmiRole",
        "arn:aws:iam::${account_id}:role/TDRJenkinsNodeLambdaRoleIntg",
        "arn:aws:iam::${account_id}:role/TDRJenkinsNodeReadParamsRoleIntg",
        "arn:aws:iam::${account_id}:role/TDRJenkinsNodeRoleIntg",
        "arn:aws:iam::${account_id}:role/TDRJenkinsNodeS3ExportRoleIntg",
        "arn:aws:iam::${account_id}:role/TDRJenkinsPublishRole",
        "arn:aws:iam::${account_id}:role/TDRJenkinsRunSsmRoleIntg",
        "arn:aws:iam::${account_id}:role/TDRScriptsTerraformRoleIntg",
        "arn:aws:iam::${account_id}:role/TDRTerraformAssumeRoleIntg",
        "arn:aws:iam::${account_id}:role/TDRTerraformAssumeRoleSbox",
        "arn:aws:iam::${account_id}:role/TDRJenkinsRunEC2DescribeInstancesIntg",
        "arn:aws:iam::${account_id}:role/TDRJenkinsDeployServiceUnavailableRoleIntg",
        "arn:aws:s3:::tdr-releases-mgmt",
        "arn:aws:s3:::tdr-releases-mgmt/*"
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
