export IGW
export ROUTE_TABLE
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

