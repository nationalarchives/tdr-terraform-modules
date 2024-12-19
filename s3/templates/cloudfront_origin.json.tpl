{
  "Version": "2012-10-17",
  "Id": "CloudfrontUploadBucketPolicy",
  "Statement": [
    %{ for grant in canonical_user_grants ~}
    {
      "Sid": "GrantPermissions-${grant.id}",
      "Effect": "Allow",
      "Principal": {
          "AWS": "${grant.id}"
      },
      "Action": ${grant.permissions},
      "Resource": [
          "arn:aws:s3:::${bucket_name}",
          "arn:aws:s3:::${bucket_name}/*"
      ]
    },
    %{ endfor ~}
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${cloudfront_oai}"
      },
      "Action": [
        "s3:PutObject",
        "s3:PutObjectTagging"
      ],
      "Resource": "arn:aws:s3:::${bucket_name}/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${account_id}:role/TDRYaraAVV2LambdaRole${title_environment}"
        ]
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::tdr-upload-files-cloudfront-dirty-${environment}/*"
    },
    {
        "Effect": "Allow",
        "Principal": {
            "Service": [
                "cloudfront.amazonaws.com"
            ]
        },
        "Action": [
            "s3:PutObject",
            "s3:PutObjectTagging"
        ],
        "Resource": [
            "arn:aws:s3:::${bucket_name}",
            "arn:aws:s3:::${bucket_name}/*"
        ],
        "Condition": {
            "StringEquals": {
                "AWS:SourceArn": ${cloudfront_distribution_arns}
            }
        }
    },
    {
      "Sid": "AllowSSLRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": [
        "arn:aws:s3:::${bucket_name}",
        "arn:aws:s3:::${bucket_name}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      },
      "Principal": "*"
    }
  ]
}
