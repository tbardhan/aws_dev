# Create the IAM Role for the EC2 Launch group
#
# Define the Template file
RoleName="LabEC2LaunchGroupRole"
RoleDesc="LabRolewithEC2S3Access"

#RolePolicy="file://1-RoleNamePolicy.json"
#CFFile="file://1-CustomPolicy.json"
#
# Create the Role with a generic policy document
aws iam create-role --role-name $RoleName --description $RoleDesc --assume-role-policy-document "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"ec2.amazonaws.com\"]},\"Action\":[\"sts:AssumeRole\"]}]}"
#	Add the policy to the role
aws iam attach-role-policy \
	--policy-arn arn:aws:iam::aws:policy/AmazonSSMFullAccess \
	--role-name $RoleName
#	Add the policy to the role
aws iam attach-role-policy \
	--policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess \
	--role-name $RoleName

# Now we have to create an Instance Profile for this role (match the RoleName)
aws iam create-instance-profile --instance-profile-name $RoleName
# Now we have to attach the Instance-profile to the Role
aws iam add-role-to-instance-profile --role-name $RoleName --instance-profile-name $RoleName
