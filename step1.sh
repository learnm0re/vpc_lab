export VPC
export SUBNET
export SUBNET0
VPC=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16  \
--tag-specifications ResourceType=vpc,Tags='[{Key=Name,Value="Demo"},{Key=Owner,Value="genUSA Team"}]' \
--query Vpc.VpcId --output text)


SUBNET=$(aws ec2 create-subnet --vpc-id $VPC --cidr-block 10.0.1.0/24 \
--query 'Subnet.{SubnetId:SubnetId}' --output text)

SUBNET0=$(aws ec2 create-subnet --vpc-id $VPC --cidr-block 10.0.0.0/24 \
--query 'Subnet.{SubnetId:SubnetId}' --output text)
