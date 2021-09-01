#!/usr/bin/env bash
echo ECS_CLUSTER=${jenkins_cluster_name} > /etc/ecs/ecs.config
chown 1000:1000 /var/run/docker*
yum install -y amazon-cloudwatch-agent
amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:${agent_policy_parameter_name}