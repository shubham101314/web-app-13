#!/bin/bash
exec > /var/log/user-data.log 2>&1

echo "===== USER DATA SCRIPT STARTED ====="

yum update -y
yum install -y nginx aws-cli

systemctl start nginx
systemctl enable nginx

echo "Nginx installed and started"

# Get instance ID (IMDSv2 safe)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s)

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s \
  http://169.254.169.254/latest/meta-data/instance-id)

REGION="ap-south-1"

echo "Instance ID: $INSTANCE_ID"
echo "Region: $REGION"

# Background watchdog
(
  echo "Watchdog started - waiting 120 seconds..."
  sleep 120

  echo "Checking SSH login activity..."

  # BETTER login detection
  LOGIN_COUNT=$(ss -tnp | grep ':22' | grep ESTAB | wc -l)

  echo "Active SSH connections: $LOGIN_COUNT"

  if [ "$LOGIN_COUNT" -eq 0 ]; then
    echo "No SSH login detected. Terminating instance..."

    aws ec2 terminate-instances \
      --instance-ids "$INSTANCE_ID" \
      --region "$REGION"

    echo "Termination command sent."
  else
    echo "SSH login detected. Instance will NOT terminate."
  fi

) &

echo "===== USER DATA SCRIPT COMPLETED ====="
