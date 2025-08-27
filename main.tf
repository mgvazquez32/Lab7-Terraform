# VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "lab-vpc" }
}

# ------- Subnets (us-east-1a todas; podés repartir a 1b si querés) -------
# Públicas
resource "aws_subnet" "lab_public_subnet1" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "lab-subnet-public1" }
}

resource "aws_subnet" "lab_public_subnet2" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "lab-subnet-public2" }
}

# Privadas
resource "aws_subnet" "lab_private_subnet1" {
  vpc_id            = aws_vpc.lab_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "lab-subnet-private1" }
}

resource "aws_subnet" "lab_private_subnet2" {
  vpc_id            = aws_vpc.lab_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "lab-subnet-private2" }
}

# ------- Route Tables (sin rutas por defecto a Internet en sandbox) -------
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.lab_vpc.id
  tags   = { Name = "lab-rtb-public" }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.lab_vpc.id
  tags   = { Name = "lab-rtb-private1" }
}

# ------- Asociaciones de TODAS las subnets a su tabla correspondiente ------
# Públicas -> public_route_table
resource "aws_route_table_association" "lab_rt_assoc_public_1" {
  subnet_id      = aws_subnet.lab_public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "lab_rt_assoc_public_2" {
  subnet_id      = aws_subnet.lab_public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Privadas -> private_route_table
resource "aws_route_table_association" "lab_rt_assoc_private_1" {
  subnet_id      = aws_subnet.lab_private_subnet1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "lab_rt_assoc_private_2" {
  subnet_id      = aws_subnet.lab_private_subnet2.id
  route_table_id = aws_route_table.private_route_table.id
}
# Security Group para HTTP
resource "aws_security_group" "web_sg" {
  name        = "web-security-group" 
  description = "Enable HTTP access"
  vpc_id      = aws_vpc.lab_vpc.id

  # HTTP 80 desde cualquier origen
  ingress {
    description      = "Permit web requests"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Egresos liberados (recomendado por defecto)
  egress {
    description      = "Allow all egress traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Web Security Group"
  }
}
# AMI Amazon Linux 2 (x86_64, HVM, gp2) más reciente en us-east-1
data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Instancia EC2 
resource "aws_instance" "web1" {
  ami                         = data.aws_ami.al2.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.lab_public_subnet2.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sg.id]

  user_data = file("${path.module}/user_data.sh")

  # Almacenamiento
  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  tags = {
    Name    = "web1"
    EC2-LAB = "Web Server 1"
  }
}
# Internet Gateway
resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "lab-igw"
  }
}

# Ruta default en la tabla de ruteo pública hacia el IGW
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.lab_igw.id
}
