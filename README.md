<p align="center">
  <a href="https://www.uit.edu.vn/"><img src="https://www.uit.edu.vn/sites/vi/files/banner.png"></a>
<h1 align="center"><b>NT548.P21 - DevOps Technology and Applications</b></h1>
  
---
  
# Author Information
**Group 21**

- **Le Binh Nguyen** - 22520969
- **Dang Huu Phat** - 22521065
- **Chau The Vi** - 22521653

**Lecturer**: Mr. Le Anh Tuan - tuanla@uit.edu.vn

---

## Verify Deployed Components

You can verify that all infrastructure components have been correctly deployed using the provided script: `test_infra.sh`.

This script checks:

- VPC and Subnets
- Internet Gateway and NAT Gateway
- Route Tables
- Security Groups
- EC2 Outputs (Public and Private IPs)

### 🔹 Step 1: Ensure script is executable

```bash
chmod +x test_infra.sh
```

---

### 🔹 Step 2: Run the script

Use one of the following depending on your provisioning method:

#### If using **Terraform**:

```bash
./test_infra.sh terraform
```

#### If using **CloudFormation**:

```bash
./test_infra.sh cloudformation
```

---

### 🔹 Output Example

The script will print out each test result with a ✅ or ❌ symbol, along with resource IDs (e.g., VPC ID, subnet ID) to help verify connectivity and correct associations between components.

Our output:

```bash
=== Testing VPC and Networking ===

✅ VPC check (ID: vpc-069833fe845287414) successful
✅ Public Subnet check (ID: subnet-06e09c2dc1dba0b9c) successful
✅ Private Subnet check (ID: subnet-042c19c356b582726) successful
✅ Internet Gateway check (ID: igw-01f809493da26254f) successful
✅ NAT Gateway check (ID: nat-0821ab49627245ddc) successful

=== Testing Route Tables ===

✅ Public Route Table check (ID: rtb-082dc12f39d742ef9) successful
✅ Private Route Table check (ID: rtb-0ea9557c442ab9881) successful

=== Testing Security Groups ===

✅ Public Security Group check (ID: sg-0922de6585d01db9a) successful
✅ Private Security Group check (ID: sg-0edb72957451e9669) successful
✅ Default Security Group check (ID: sg-0e51d574646949141) successful

=== Testing EC2 Instances ===

✅ Public EC2 Instance check (ID: i-0d5f57b238563997b) successful
✅ Private EC2 Instance check (ID: i-0d62913442edab455) successful
```

This confirms that all components are provisioned and configured correctly.

---

# EC2 Connectivity Testing

After provisioning the infrastructure using Terraform or CloudFormation, you can test connectivity between the EC2 instances as follows:

---

## 1: Get EC2 IP Addresses

## 2: SSH into Public EC2

Grant permission to your private key and connect to the public EC2 instance:

```bash
chmod 400 lab1.pem
ssh -i lab1.pem ec2-user@$PUBLIC_IP
```

Output:
![SSH to Public EC2](./docs/terrafrom_ssh_to_public_ec2.png)

---

## 3: SSH into Private EC2 via Public EC2

### On your local machine:

Start the SSH agent and add your key:

```bash
eval "$(ssh-agent -s)"
ssh-add lab1.pem
```

Then SSH into the **public EC2 with agent forwarding**:

```bash
ssh -A -i lab1.pem ec2-user@$PUBLIC_IP
```

Once inside the public EC2, connect to the private EC2:

```bash
ssh ec2-user@$PRIVATE_IP
```

Output:
![SSH to Private EC2](./docs/terraform_ssh_to_private_ec2_from_public_ec2.png)

---
