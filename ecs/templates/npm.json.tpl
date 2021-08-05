[
  {
    "cpu": 1024,
    "memory": 4096,
    "image": "${account}.dkr.ecr.eu-west-2.amazonaws.com/jenkins-build-npm",
    "name": "npm",
    "taskRoleArn": "arn:aws:iam::${account}:role/TDRJenkinsPublishRole",
    "compatibilities": ["FARGATE"],
    "networkMode": "awsvpc",
    "secrets": [
      {
        "valueFrom": "/mgmt/github/gpg/passphrase",
        "name": "PASSPHRASE"
      },
      {
        "valueFrom": "/mgmt/github/gpg/key",
        "name": "GPG_KEY"
      },
      {
        "valueFrom": "/mgmt/github/gpg/id",
        "name": "GPG_KEY_ID"
      }
    ]
  }
]
