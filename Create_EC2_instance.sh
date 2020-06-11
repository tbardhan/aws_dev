# Create Stack for DEMO Platform
StackName="Stack-DW-EC2"
Enironment="DEV"
IAMInstanceProfile="LabEC2LaunchGroupRole"
# Assuming the VPC is Already Defined we need to get the VPC information
# Ask ADMIN for the VPC Name that is being used for DEMO
VpcName="DataWarehouse-VPC"
# Define SSH Key
KeyID="jacob_azure_id"
# Define the Template file
CFFile="file://Create_EC2_instance.yaml"

# Test the configuration file
aws cloudformation validate-template --template-body $CFFile >> /dev/null
if [ "$?" = "1" ]; then
	echo "Cloud Formation Template Validation failed!" 1>&2
	exit 1
fi

# Get the Default VPC ID from AWS
VpcID=`aws ec2 describe-vpcs --filter Name=tag:Name,Values=\$VpcName --query 'Vpcs[*].{id:VpcId}' --output text`
#echo VpcName=$VpcName
#echo VpcID=$VpcID

# Code Update - We need to define the security group
# Get Default Security Group for AZ - Picking the 1st one for now
DefaultVPCSecurityGroup=`aws ec2 describe-security-groups --filter "Name=group-name,Values=default" --query 'SecurityGroups[*].{Name:GroupId}' --output text | awk 'NR==1{print $1}'`

# Get the  Subnet IDs based on the above Defined VPC (Assuming 2 Subnets)
# Getting the 1st Subnet
PrivateSubnetAZ1=`aws ec2 describe-subnets --filter "Name=vpc-id,Values=$VpcID" --filter "Name=tag:Name,Values=*DW-Private*"  --query "Subnets[*].{id:SubnetId}" --output text | awk 'NR==1{print $1}'`
# Getting the 2nd Subnet
PrivateSubnetAZ2=`aws ec2 describe-subnets --filter "Name=vpc-id,Values=$VpcID" --filter "Name=tag:Name,Values=*DW-Private*"  --query "Subnets[*].{id:SubnetId}" --output text | awk 'NR==2{print $1}'`
# Getting the 1st Subnet
PublicSubnetAZ1=`aws ec2 describe-subnets --filter "Name=vpc-id,Values=$VpcID" --filter "Name=tag:Name,Values=*DW-Public*"  --query "Subnets[*].{id:SubnetId}" --output text | awk 'NR==1{print $1}'`
# Getting the 2nd Subnet
PublicSubnetAZ2=`aws ec2 describe-subnets --filter "Name=vpc-id,Values=$VpcID" --filter "Name=tag:Name,Values=*DW-Public*"  --query "Subnets[*].{id:SubnetId}" --output text | awk 'NR==2{print $1}'`

# Cloud Watch Information Extraction
# Fixed Values (be careful)
# CloudWatch Cloudformation template NAME: DW-CloudWatch-Log-Group-Stack
# CloudWatch Cloudformation template OUTPUT for CloudWatchLogGroupName: CloudWatchLogGroupName
# Extact the Value for the CloudWatch Stack output CloudWatchLogGroupName
CloudWatchStackName="DW-CloudWatch-Log-Group-Stack"
CloudWatchLogGroupName=`aws cloudformation describe-stacks --stack-name $CloudWatchStackName --query "Stacks[0].Outputs[?OutputKey=='CloudWatchLogGroupName'].OutputValue" --output text`

# Print all the Parameters we have $DEBUG
Echo "##### Defined Variables #####"
echo "VPC ID: $VpcID"
echo "VPC Name: $VpcName"
echo "VPC Default Security Group: $DefaultVPCSecurityGroup"
echo "PrivateSubnetAZ1: $PrivateSubnetAZ1"
echo "PrivateSubnetAZ2: $PrivateSubnetAZ2"
echo "PublicSubnetAZ1: $PublicSubnetAZ1"
echo "PublicSubnetAZ2: $PublicSubnetAZ2"
echo "-"
echo "CloudWatchStackName: $CloudWatchStackName"
echo "CloudWatchLogGroupName: $CloudWatchLogGroupName"

# Check if the above variable are blank
# Checking for only the Variable we require for the CloudFormation Script
if [ -z $VpcID ] || [ -z $DefaultVPCSecurityGroup ] || [ -z PrivateSubnetAZ1 ] || [ -z PrivateSubnetAZ2 ] ; then
	echo "\nSomething is wrong with getting the VPC or the SubNets !!!!"
	echo "Exiting !!!!"
	exit 1
else
	echo "Creating the Stack ....... "
	# Create the Cloud Formation Stack
	aws cloudformation create-stack \
	--stack-name $StackName \
	--template-body $CFFile \
	--parameters \
	ParameterKey=TagValue1,ParameterValue=$StackName \
	ParameterKey=TagValue2,ParameterValue=$Environment \
	ParameterKey=VpcId,ParameterValue=$VpcID \
	ParameterKey=SecurityGroup,ParameterValue=$DefaultVPCSecurityGroup \
	ParameterKey=IAMInstanceProfile,ParameterValue=$IAMInstanceProfile \
	ParameterKey=PrivateSubnet,ParameterValue=\"$PrivateSubnetAZ1\" \
	ParameterKey=PublicSubnet,ParameterValue=\"$PublicSubnetAZ1\" \
	ParameterKey=KeyName,ParameterValue=$KeyID 
fi
