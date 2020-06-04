# Deploy AWS Inspector Agent via SSM to EC2 Instances
# Deploy to Private EC2 Instance
aws ssm send-command  --document-name "AmazonInspector-ManageAWSAgent" --targets Key=tag:Name,Values=DW-EC2Instance-Private
# Deploy to Public EC2 Instance
aws ssm send-command  --document-name "AmazonInspector-ManageAWSAgent" --targets Key=tag:Name,Values=DW-EC2Instance-Public
