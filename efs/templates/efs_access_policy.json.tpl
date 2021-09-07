{
  "Version": "2012-10-17",
  "Id": "efs-policy-backend-checks",
  "Statement": [
    {
      "Sid": "efs-statement-backend-checks",
      "Effect": "Allow",
      "Principal": {
        "AWS": ${policy_roles}
      },
      "Action": [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite"
      ],
      "Resource": "${file_system_arn}"
    },
    {
      "Sid": "efs-statement-bastion",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${bastion_role}"
    },
    "Action": "elasticfilesystem:ClientMount",
    "Resource": "${file_system_arn}"
    }
  ]
}
