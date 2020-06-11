#Update Glue Settings
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

 

kmskeyarn=`aws cloudformation describe-stacks --stack-name ${KMSStackName} --query "Stacks[0].Outputs[?OutputKey=='KmsKeyArn'].OutputValue" --output text`

 

aws glue put-data-catalog-encryption-settings --data-catalog-encryption-settings "{\"EncryptionAtRest\":{\"CatalogEncryptionMode\": \"SSE-KMS\",\"SseAwsKmsKeyId\": \"${kmskeyarn}\"},\"ConnectionPasswordEncryption\":{\"ReturnConnectionPasswordEncrypted\": true,\"AwsKmsKeyId\": \"${kmskeyarn}\"}}"
