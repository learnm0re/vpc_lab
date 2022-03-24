https://docs.aws.amazon.com/vpc/latest/userguide/vpc-subnets-commands-example.html

The following example uses AWS CLI commands to create a nondefault VPC with an IPv4 CIDR block, 
and a public and private subnet in the VPC. After you've created the VPC and subnets, 
you can launch an instance in the public subnet and connect to it.

You will create the following AWS resources:

- A VPC
- Two subnets
- An internet gateway
- A route table
- An EC2 instance

## Step 1 Create a VPC and subnets

The first step is to create a VPC and two subnets. This example uses the CIDR block 10.0.0.0/16 for the VPC.

```
VPC=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16  \
--tag-specifications ResourceType=vpc,Tags='[{Key=Name,Value="Demo"},{Key=Owner,Value="genUSA Team"}]' \
--query Vpc.VpcId --output text)


SUBNET=$(aws ec2 create-subnet --vpc-id $VPC --cidr-block 10.0.1.0/24 \
--query 'Subnet.{SubnetId:SubnetId}' --output text)

SUBNET0=$(aws ec2 create-subnet --vpc-id $VPC --cidr-block 10.0.0.0/24 \
--query 'Subnet.{SubnetId:SubnetId}' --output text)

```

## Step 2 Make your subnet public

After you've created the VPC and subnets, you can make 
one of the subnets a public subnet 
by attaching an internet gateway to your VPC, 
creating a custom route table, and configuring routing for the subnet to the internet gateway.

```
IGW=$(aws ec2 create-internet-gateway \
--query InternetGateway.InternetGatewayId --output text)

aws ec2 attach-internet-gateway --vpc-id $VPC --internet-gateway-id $IGW

ROUTE_TABLE=$(aws ec2 create-route-table --vpc-id $VPC \
--query RouteTable.RouteTableId --output text)

aws ec2 create-route --route-table-id $ROUTE_TABLE --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW

aws ec2 describe-route-tables --route-table-id $ROUTE_TABLE

aws ec2 describe-subnets --filters "Name=vpc-id,Values="$VPC \
--query "Subnets[*].{ID:SubnetId,CIDR:CidrBlock}"

aws ec2 associate-route-table  --subnet-id $SUBNET \
 --route-table-id $ROUTE_TABLE

aws ec2 modify-subnet-attribute --subnet-id $SUBNET --map-public-ip-on-launch

```

## Step 3 Launch an instance into your subnet

To test that your subnet is public and that instances in the subnet are accessible over the internet, 
launch an instance into your public subnet and connect to it. First, 
you must create a security group to associate with your instance, 
and a key pair with which you'll connect to your instance. 

```

aws ec2 create-key-pair --key-name genUSAPair --query "KeyMaterial" --output text > genUSAPair.pem

chmod 400 genUSAPair.pem


SECURITY_GROUP=$(aws ec2 create-security-group --group-name genUSA \
 --description "Security group for SSH access" \
 --vpc-id $VPC --query "GroupId" --output text)

aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP \
 --protocol tcp --port 22 --cidr 0.0.0.0/0

```
Query SSM for the latest Amazon Linux 2 AMI ID

```
AMI_ID=$(aws ssm get-parameters --names \
   /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
   --query 'Parameters[0].[Value]' --output text)

```

```
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type t2.micro \
--key-name genUSAPair --security-group-ids $SECURITY_GROUP --subnet-id $SUBNET \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=genUSA}]' \
--query Instances[0].InstanceId --output text)



aws ec2 describe-instances --instance-id $INSTANCE_ID \
--query "Reservations[*].Instances[*].{State:State.Name,Address:PublicIpAddress}"

IP_ADDRESS=$(aws ec2 describe-instances --instance-id $INSTANCE_ID \
--query "Reservations[*].Instances[*].PublicIpAddress" --output text)

```
When your instance is in the running state, you can connect to it 
using an SSH client on a Linux or Mac OS X computer by using the following command:

```
ssh -i "genUSAPair.pem" ec2-user@$IP_ADDRESS
```

## Step 4: Clean up

```
aws ec2 terminate-instances --instance-ids $INSTANCE_ID

aws ec2 delete-security-group --group-id $SECURITY_GROUP

aws ec2 delete-subnet --subnet-id $SUBNET
aws ec2 delete-subnet --subnet-id $SUBNET0

aws ec2 delete-route-table --route-table-id $ROUTE_TABLE

aws ec2 detach-internet-gateway --internet-gateway-id $IGW --vpc-id $VPC

aws ec2 delete-internet-gateway --internet-gateway-id $IGW

aws ec2 delete-vpc --vpc-id $VPC
```

