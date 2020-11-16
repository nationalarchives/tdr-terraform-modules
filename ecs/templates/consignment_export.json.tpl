[
  {
    "name": "consignmentexport",
    "image": "${management_account}.dkr.ecr.eu-west-2.amazonaws.com/consignment-export:${app_environment}",
    "networkMode": "awsvpc",
    "secrets": [
      {
        "name": "CLIENT_SECRET",
        "valueFrom": "${backend_client_secret_path}"
      }
    ],
    "environment": [
      {
        "name": "CLEAN_BUCKET",
        "value": "${clean_bucket}"
      },
      {
        "name": "OUTPUT_BUCKET",
        "value": "${output_bucket}"
      },
      {
        "name": "API_URL",
        "value": "${api_url}"
      },
      {
        "name": "AUTH_URL",
        "value": "${auth_url}"
      }
    ],
    "mountPoints": [
      {
        "containerPath": "/tmp/export",
        "sourceVolume": "consignmentexport"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group_name}",
        "awslogs-region": "eu-west-2",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]