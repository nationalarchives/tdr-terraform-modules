{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "ec2-user"
  },
  "metrics": {
    "metrics_collected": {
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "/"
        ],
        "append_dimensions": {
          "server_name": "${server_name}"
        }
      }
    }
  }
}