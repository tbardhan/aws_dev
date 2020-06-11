# Create the CloudFormation Stack
#
# Define the Template file
CFFile="file://Create_VPC.yaml"
StackName="DataWarehouse-VPC"
Environment="DEV"

# Region
# Region has already been selected at the aws cli configuraion Selection
# No no requirement to set the region
# Define AZ or get current AZ's using query
AZ1=`aws ec2 describe-availability-zones --output text | awk 'NR==1{print $8}'`
AZ2=`aws ec2 describe-availability-zones --output text | awk 'NR==2{print $8}'`

# Test the CloudFormation Template file
aws cloudformation validate-template --template-body $CFFile > /dev/null
if [ "$?" = "1" ]; then
	echo "Cloud Formation Template Validation failed!" 1>&2
	exit 1
fi

# Echo Values
echo "Building Configuration with the following Values:"
echo "AZ1: $AZ1"
echo "AZ2: $AZ2"

# Create the Cloud Formation Stack
aws cloudformation create-stack \
--stack-name Stack-$StackName \
--template-body $CFFile \
--parameters \
ParameterKey=TagValue1,ParameterValue=$StackName \
ParameterKey=TagValue2,ParameterValue=$Environment \
ParameterKey=VPCName,ParameterValue=$StackName \
ParameterKey=CIDR,ParameterValue=10.0.0.0/16 \
ParameterKey=PrivateSubnet1AZName,ParameterValue=DW-PrivateSubnetAZ1 \
ParameterKey=PrivateSubnet2AZName,ParameterValue=DW-PrivateSubnetAZ2 \
ParameterKey=PrivateCidrBlock1,ParameterValue=10.0.1.0/24 \
ParameterKey=PrivateCidrBlock2,ParameterValue=10.0.2.0/24 \
ParameterKey=PrivateSubnet1AZ,ParameterValue=$AZ1 \
ParameterKey=PrivateSubnet2AZ,ParameterValue=$AZ2 \
ParameterKey=PublicSubnet1AZName,ParameterValue=DW-PublicSubnetAZ1 \
ParameterKey=PublicSubnet2AZName,ParameterValue=DW-PublicSubnetAZ2 \
ParameterKey=PublicCidrBlock1,ParameterValue=10.0.3.0/24 \
ParameterKey=PublicCidrBlock2,ParameterValue=10.0.4.0/24 \
ParameterKey=PublicSubnet1AZ,ParameterValue=$AZ1 \
ParameterKey=PublicSubnet2AZ,ParameterValue=$AZ2
