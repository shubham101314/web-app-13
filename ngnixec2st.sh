#!/bin/bash

# ===== CONFIG =====
AMI_ID="ami-019715e0d74f695be"
INSTANCE_TYPE="t2.micro"
KEY_NAME="110-pem-key"
SECURITY_GROUP_ID="sg-075c92fc2d1772b35"
SUBNET_ID="subnet-0664257d699b9e4f6"
INSTANCE_PROFILE_NAME="104-EC2-Role"
TAG_NAME="my-ec2-instance"
USER_DATA_FILE="ngnixuds.sh"

STATE_FILE=".ec2_instance_id"

# ===== FUNCTIONS =====

start_instance() {
  INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$SECURITY_GROUP_ID" \
    --subnet-id "$SUBNET_ID" \
    --iam-instance-profile Name="$INSTANCE_PROFILE_NAME" \
    --user-data file://"$USER_DATA_FILE" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$TAG_NAME}]" \
    --query "Instances[0].InstanceId" \
    --output text)

  echo "$INSTANCE_ID" > "$STATE_FILE"

  echo "EC2 instance started"
  echo "Instance ID: $INSTANCE_ID"

  aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

  PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0].PublicIpAddress" \
    --output text)

  echo "Public IP: $PUBLIC_IP"
}

terminate_instance() {
  if [ ! -f "$STATE_FILE" ]; then
    echo "No instance ID found. Nothing to terminate."
    exit 1
  fi

  INSTANCE_ID=$(cat "$STATE_FILE")

  aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"
  aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID"

  rm -f "$STATE_FILE"

  echo "EC2 instance terminated"
  echo "Instance ID: $INSTANCE_ID"
}

# ===== MAIN =====
case "$1" in
  start)
    start_instance
    ;;
  terminate)
    terminate_instance
    ;;
  *)
    echo "Usage: $1 {start|terminate}"
    exit 1
    ;;
esac
