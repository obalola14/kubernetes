resource "aws_vpc" "git_hub_actions_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.git_hub_actions_vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.git_hub_actions_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "github-actions"
  }
}

resource "aws_route_table" "internet_route" {
  vpc_id = aws_vpc.git_hub_actions_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "rtba" {
  subnet_id     = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.internet_route.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "github_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  tags = {
    Name = "github-actions"
  }
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  key_name = aws_key_pair.deployer.key_name
  associate_public_ip_address = true
  }

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow port 80 inbound traffic"
  vpc_id      = aws_vpc.git_hub_actions_vpc.id

  tags = {
    Name = "allow_tls"
  }
}

  resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = 0.0.0.0/0
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

  resource "aws_vpc_security_group_egress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = 0.0.0.0/0
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

  resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = 0.0.0.0/0
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

  resource "aws_vpc_security_group_egress_rule" "allow_tls_https" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = 0.0.0.0/0
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

  resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

  resource "aws_vpc_security_group_egress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  }

resource "aws_key_pair" "deployer" {
  key_name   = "github_action_key"
  public_key = tls_private_key.my-key.public_key_openssh
}

resource "tls_private_key" "my-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "pem-key" {
  content  = tls_private_key.my-key.private_key_openssh
  filename = "${path.module}/github_action_key.pem"
  file_permission = 0600
}


