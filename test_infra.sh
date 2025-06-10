#!/bin/bash
# filepath: e:\App\Git\repos\NT548.P21-Lab1\test_infra.sh
# Usage: ./test_infra.sh [cloudformation|terraform]

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
    echo -e "\n${YELLOW}=== $1 ===${NC}\n"
}

check_service() {
    local desc="$1"
    local code="$2"
    if [ "$code" -eq 0 ]; then
        echo -e "${GREEN}✅ $desc successful${NC}"
    else
        echo -e "${RED}❌ $desc failed${NC}"
    fi
}

check_stack_exists() {
    aws cloudformation describe-stacks --stack-name lab1 > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Stack 'lab1' not found. Exiting.${NC}"
        exit 1
    fi
}

get_outputs() {
    if [ "$1" == "cloudformation" ]; then
        PUBLIC_IP=$(aws cloudformation describe-stacks --stack-name lab1 --query 'Stacks[0].Outputs[?OutputKey==`PublicEc2IP`].OutputValue' --output text)
        PRIVATE_IP=$(aws cloudformation describe-stacks --stack-name lab1 --query 'Stacks[0].Outputs[?OutputKey==`PrivateEc2Ip`].OutputValue' --output text)
    else
        PUBLIC_IP=$(terraform output -raw public_ec2_ip)
        PRIVATE_IP=$(terraform output -raw private_ec2_ip)
    fi
}

test_network() {
    print_header "Testing VPC and Networking"

    VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=my-vpc" --query 'Vpcs[0].VpcId' --output text 2>/dev/null)
    check_service "VPC check (ID: $VPC_ID)" $?

    PUB_SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=public-subnet" --query 'Subnets[0].SubnetId' --output text 2>/dev/null)
    check_service "Public Subnet check (ID: $PUB_SUBNET_ID)" $?

    PRI_SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=private-subnet" --query 'Subnets[0].SubnetId' --output text 2>/dev/null)
    check_service "Private Subnet check (ID: $PRI_SUBNET_ID)" $?

    IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=tag:Name,Values=my-igw" --query 'InternetGateways[0].InternetGatewayId' --output text 2>/dev/null)
    check_service "Internet Gateway check (ID: $IGW_ID)" $?

    NAT_ID=$(aws ec2 describe-nat-gateways --filter "Name=state,Values=available" --query 'NatGateways[0].NatGatewayId' --output text 2>/dev/null)
    check_service "NAT Gateway check (ID: $NAT_ID)" $?
}

test_route_tables() {
    print_header "Testing Route Tables"

    PUB_RT_ID=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=public-rt" --query 'RouteTables[0].RouteTableId' --output text 2>/dev/null)
    check_service "Public Route Table check (ID: $PUB_RT_ID)" $?

    PRI_RT_ID=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=private-rt" --query 'RouteTables[0].RouteTableId' --output text 2>/dev/null)
    check_service "Private Route Table check (ID: $PRI_RT_ID)" $?
}

test_security_groups() {
    print_header "Testing Security Groups"

    PUB_SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=public-sg" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null)
    check_service "Public Security Group check (ID: $PUB_SG_ID)" $?

    PRI_SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=private-sg" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null)
    check_service "Private Security Group check (ID: $PRI_SG_ID)" $?

    DEF_SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=default" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null)
    check_service "Default Security Group check (ID: $DEF_SG_ID)" $?
}

test_ec2_instances() {
    print_header "Testing EC2 Instances"

    PUB_EC2_ID=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=public-ec2" "Name=instance-state-name,Values=running" \
        --query 'Reservations[0].Instances[0].InstanceId' \
        --output text 2>/dev/null)
    check_service "Public EC2 Instance check (ID: $PUB_EC2_ID)" $?

    PRI_EC2_ID=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=private-ec2" "Name=instance-state-name,Values=running" \
        --query 'Reservations[0].Instances[0].InstanceId' \
        --output text 2>/dev/null)
    check_service "Private EC2 Instance check (ID: $PRI_EC2_ID)" $?
}


check_terraform_outputs() {
    PUBLIC_IP=$(terraform output -raw public_ec2_ip 2>/dev/null)
    if [[ -z "$PUBLIC_IP" || "$PUBLIC_IP" == *"Warning:"* ]]; then
        echo -e "${RED}❌ Terraform output 'public_ec2_ip' not found or empty. Did you define it properly?${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ Terraform output 'public_ec2_ip' found: $PUBLIC_IP${NC}"
    fi

    PRIVATE_IP=$(terraform output -raw private_ec2_ip 2>/dev/null)
    if [[ -z "$PRIVATE_IP" || "$PRIVATE_IP" == *"Warning:"* ]]; then
        echo -e "${RED}❌ Terraform output 'private_ec2_ip' not found or empty. Did you define it properly?${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ Terraform output 'private_ec2_ip' found: $PRIVATE_IP${NC}"
    fi
}


main() {
    if [ -z "$1" ]; then
        echo "Usage: $0 [cloudformation|terraform]"
        exit 1
    fi

    if [ "$1" == "cloudformation" ]; then
        check_stack_exists
    elif [ "$1" == "terraform" ]; then
        check_terraform_outputs
    else
        echo -e "${RED}❌ Invalid deployment type: $1. Use 'cloudformation' or 'terraform'.${NC}"
        exit 1
    fi

    get_outputs $1
    test_network
    test_route_tables
    test_security_groups
    test_ec2_instances
}

main "$@"
