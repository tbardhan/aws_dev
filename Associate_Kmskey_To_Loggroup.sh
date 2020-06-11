#Associate KMS Key to CloudWatch Log Groups
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
LogGroupStackName=$(prop 'LogGroupStackName')
#echo ${KMSStackName}

loggroup=`aws cloudformation describe-stacks --stack-name ${LogGroupStackName} --query "Stacks[0].Outputs[?OutputKey=='CloudWatchLogGr>
kmskeyarn=`aws cloudformation describe-stacks --stack-name ${KMSStackName} --query "Stacks[0].Outputs[?OutputKey=='KmsKeyArn'].OutputV>
#echo ${loggroup}
echo ${kmskeyarn}
aws logs associate-kms-key --log-group-name "${loggroup}" --kms-key-id "${kmskeyarn}"
