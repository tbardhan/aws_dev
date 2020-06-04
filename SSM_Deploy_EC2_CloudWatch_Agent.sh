# Deploy AWS CloudWatch Agent via SSM to EC2 Instances
# Deploy to Private EC2 Instance
aws ssm send-command  --document-name "AmazonCloudWatch-ManageAgent" --targets Key=tag:Name,Values=DW-EC2Instance-Private
# Deploy to Public EC2 Instance
aws ssm send-command  --document-name "AmazonCloudWatch-ManageAgent" --targets Key=tag:Name,Values=DW-EC2Instance-Public
