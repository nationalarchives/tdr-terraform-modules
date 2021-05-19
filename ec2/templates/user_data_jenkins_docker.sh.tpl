#!/usr/bin/env bash
echo ECS_CLUSTER=${jenkins_cluster_name} > /etc/ecs/ecs.config
chown 1000:1000 /var/run/docker*