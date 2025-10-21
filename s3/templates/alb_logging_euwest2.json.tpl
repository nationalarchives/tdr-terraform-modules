{
  "Id": "alb-logging-${bucket_name}",
  "Version": "2012-10-17",
  "Statement": [
  %{ if aws_backup_local_role != "" }
    {
      "Sid": "AllowSourceAWSBackupRoleAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_backup_local_role}"
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket",
        "s3:ListBucketVersions"
      ],
      "Resource": [
        "arn:aws:s3:::${bucket_name}",
        "arn:aws:s3:::${bucket_name}/*"
      ]
    },
  %{ endif }
    {
      "Sid": "AWSALBLogDeliveryWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "logdelivery.elasticloadbalancing.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::tdr-alb-logs-intg/*"
    },
    {
      "Sid": "AWSELBLogDeliveryAclCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
       },
       "Action": "s3:GetBucketAcl",
       "Resource": "arn:aws:s3:::${bucket_name}",
       "Condition": {
       "StringEquals": {
         "aws:SourceAccount": "${account_id}"
         },
         "ArnLike": {
           "aws:SourceArn": "arn:aws:logs:eu-west-2:${account_id}:*"
         }
       }
     },
     {
       "Sid": "AWSELBLogDeliveryWrite",
       "Effect": "Allow",
       "Principal": {
         "Service": "delivery.logs.amazonaws.com"
       },
       "Action": "s3:PutObject",
       "Resource": "arn:aws:s3:::${bucket_name}/*",
       "Condition": {
       "StringEquals": {
         "s3:x-amz-acl": "bucket-owner-full-control",
         "aws:SourceAccount": "${account_id}"
         },
         "ArnLike": {
           "aws:SourceArn": "arn:aws:logs:eu-west-2:${account_id}:*"
         }
       }
     }
  ]
}
