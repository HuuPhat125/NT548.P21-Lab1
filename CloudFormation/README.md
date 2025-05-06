# AWS CloudFormation Infrastructure Setup Guide

## Prerequisites

1. AWS CLI installed and configured (`aws configure`)
2. AWS account with necessary permissions
3. Existing or new **key pair** for EC2 instances
4. An **S3 bucket** to store CloudFormation templates
5. Basic knowledge of **Availability Zones** in your region

---

## File Structure

```
CloudFormation/
├── main.yaml              # Main template file
├── parameters.json        # Parameters for stack creation
├── modules/               # Module templates
│   ├── vpc.yaml
│   ├── subnet.yaml
│   ├── internet-gateway.yaml
│   ├── nat-gateway.yaml
│   ├── route-table-public.yaml
│   ├── route-table-private.yaml
│   ├── security-group-public.yaml
│   ├── security-group-private.yaml
│   └── ec2.yaml
```

---

## Deployment Steps

### 1. **Determine Availability Zones**

Before starting, identify the available Availability Zones in your region:

```bash
aws ec2 describe-availability-zones --query 'AvailabilityZones[*].ZoneName' --output text
```

> Example output: `us-east-1a us-east-1b us-east-1c`

Note down at least 2 AZs to use for subnets and EC2 instances.

---

### 2. **Find the appropriate AMI for your AZ and Region**

Retrieve the latest AMI ID for Amazon Linux 2 in your region:

```bash
aws ec2 describe-images \
  --owners amazon \
  --filters 'Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2' \
            'Name=state,Values=available' \
  --query 'Images[*].[ImageId,CreationDate]' \
  --output text | sort -k2 -r | head -n 1
```

> Note the `ImageId` (e.g., `ami-0123456789abcdef0`)

---

### 3. **Create or use a Key Pair**

View existing key pairs:

```bash
aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName'
```

If you don't have one, create a new key:

```bash
aws ec2 create-key-pair --key-name lab1 --query 'KeyMaterial' --output text > lab1.pem
chmod 400 lab1.pem
```

> Keep the `.pem` file secure; you'll need it to SSH into EC2 instances.

---

### 4. **Determine the IP address to allow SSH**

Retrieve your current IP address:

```bash
curl http://checkip.amazonaws.com
```

Then, append `/32` to restrict SSH access to this specific IP:

```json
"YOUR.IP.ADDRESS/32"
```

---

### 5. **Edit `parameters.json`**

Open the `CloudFormation/parameters.json` file and update the values:

```json
[
  {
    "ParameterKey": "KeyName",
    "ParameterValue": "your-key-name"
  },
  {
    "ParameterKey": "ImageId",
    "ParameterValue": "ami-xxxxxxxxxxxxxxxxxxx"
  },
  {
    "ParameterKey": "AvailabilityZone",
    "ParameterValue": "ap-southeast-1a"
  },
  {
    "ParameterKey": "AllowedSSHIp",
    "ParameterValue": "your-ip/32"
  },
]
```

> **Note:** The `ParameterValue` of `BucketName` must match the bucket name you will create in the next step.

---

### 6. **Create an S3 Bucket (if not already existing)**

Create a bucket with a unique name (modify the name below):

```bash
export BUCKET_NAME=your-unique-cfn-bucket-2025
aws s3 mb s3://$BUCKET_NAME
```
Open the `CloudFormation/parameters.json` file and update the values:

```json
[
  {
    "ParameterKey": "BucketName",
    "ParameterValue": "your-unique-cfn-bucket-2025"
  }
]
```
---

### 7. **Upload templates to S3**

```bash
aws s3 cp CloudFormation/ s3://$BUCKET_NAME/CloudFormation/ --recursive
```

---

### 8. **Create the Stack from the Template**

```bash
aws cloudformation create-stack \
  --stack-name lab1 \
  --template-url https://$BUCKET_NAME.s3.amazonaws.com/CloudFormation/main.yaml \
  --parameters file://CloudFormation/parameters.json \
  --capabilities CAPABILITY_IAM
```

---

## Monitoring & Outputs

### Check the stack status

```bash
aws cloudformation describe-stacks --stack-name lab1 --query 'Stacks[0].StackStatus'
```

### View the stack outputs

```bash
aws cloudformation describe-stacks --stack-name lab1 --query 'Stacks[0].Outputs'
```

---

## Cleanup

### Delete the stack

```bash
aws cloudformation delete-stack --stack-name lab1
```

### Verify deletion

```bash
aws cloudformation describe-stacks --stack-name lab1
```

---

## Troubleshooting

### View stack creation logs

```bash
aws cloudformation describe-stack-events --stack-name lab1
```

### Validate the template

```bash
aws cloudformation validate-template \
  --template-url https://$BUCKET_NAME.s3.amazonaws.com/CloudFormation/main.yaml
```

---

## Security Notes

- Do not share the `.pem` file, and store it securely on your machine
- Only allow SSH from a specific IP (`/32`)