
set -euo pipefail

# Configuration
OUTPUT_FILE="instance_info.txt"
S3_URI="s3://applicant-task/instance-105"
METADATA_URL="http://169.254.169.254"

# 1. Get Session Token for security (IMDSv2)
TOKEN=$(curl -s -X PUT "$METADATA_URL/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# 2. Gather data and save to file
{
    echo "=== AWS EC2 INSTANCE METADATA ==="
    echo "Instance ID: $(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" $METADATA_URL/meta-data/instance-id)"
    echo "Public IP: $(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" $METADATA_URL/meta-data/public-ipv4)"
    echo "Private IP: $(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" $METADATA_URL/meta-data/local-ipv4)"
    echo "Security Groups: $(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" $METADATA_URL/meta-data/security-groups)"
    echo ""
    echo "=== SYSTEM INFORMATION ==="
    echo "OS Name: $(grep '^PRETTY_NAME=' /etc/os-release | cut -d'=' -f2 | tr -d '\"')"
    echo "Active Shell Users: $(grep -E '/bin/bash|/bin/sh' /etc/passwd | cut -d: -f1 | xargs)"
} > "$OUTPUT_FILE"

echo "Data collection complete. Results saved in: $OUTPUT_FILE"
