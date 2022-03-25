export AMI_ID
export INSTANCE_ID
export IP_ADDRESS
AMI_ID=$(aws ssm get-parameters --names \
   /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
   --query 'Parameters[0].[Value]' --output text)

INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type t2.micro \
--key-name genUSAPair --security-group-ids $SECURITY_GROUP --subnet-id $SUBNET \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=genUSA}]' \
--query Instances[0].InstanceId --output text)



aws ec2 describe-instances --instance-id $INSTANCE_ID \
--query "Reservations[*].Instances[*].{State:State.Name,Address:PublicIpAddress}"

IP_ADDRESS=$(aws ec2 describe-instances --instance-id $INSTANCE_ID \
--query "Reservations[*].Instances[*].PublicIpAddress" --output text)

