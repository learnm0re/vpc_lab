
#aws ec2 create-key-pair --key-name genUSAPair --query "KeyMaterial" --output text > genUSAPair.pem

#chmod 400 genUSAPair.pem
export SECURITY_GROUP

SECURITY_GROUP=$(aws ec2 create-security-group --group-name genUSA \
 --description "Security group for SSH access" \
 --vpc-id $VPC --query "GroupId" --output text)

aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP \
 --protocol tcp --port 22 --cidr 0.0.0.0/0

