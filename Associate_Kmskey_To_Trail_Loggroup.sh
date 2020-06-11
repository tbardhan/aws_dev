#Associate KMS Key to Trail's CloudWatch Log Groups
configFile=${1}

if [ -f "${configFile}" ]
then
echo "${configFile} found."
else
echo "Unable to identify the file"
exit 0
fi
function prop {
grep -w "${1}" ${configFile}|grep -v "#${1}"|cut -d'=' -f 2
}
KMSStackName=$(prop 'KMSStackName')
TrailLogGroupStackName=$(prop 'TrailLogGroupStackName')


loggroup=`aws cloudformation describe-stacks --stack-name ${TrailLogGroupStackName} --query "Stacks[0].Outputs[?OutputKey=='TrailLogGroup'].OutputValue" --output text`
kmskeyarn=`aws cloudformation describe-stacks --stack-name ${KMSStackName} --query "Stacks[0].Outputs[?OutputKey=='KmsKeyArn'].OutputValue" --output text`

aws logs associate-kms-key --log-group-name "${loggroup}" --kms-key-id "${kmskeyarn}"