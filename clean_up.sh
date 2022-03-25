#aws ec2 terminate-instances --instance-ids $INSTANCE_ID

#aws ec2 delete-security-group --group-id $SECURITY_GROUP

aws ec2 delete-subnet --subnet-id $SUBNET
aws ec2 delete-subnet --subnet-id $SUBNET0

aws ec2 delete-route-table --route-table-id $ROUTE_TABLE

aws ec2 detach-internet-gateway --internet-gateway-id $IGW --vpc-id $VPC

aws ec2 delete-internet-gateway --internet-gateway-id $IGW

aws ec2 delete-vpc --vpc-id $VPC
