provider "aws" {
  region = "us-east-1"  # 適切なリージョンに変更してください
}

# VPCの作成
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "ExampleVPC"
  }
}

# インターネットゲートウェイの作成
resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = "ExampleIGW"
  }
}

# ルートテーブルの作成
resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }

  tags = {
    Name = "ExampleRouteTable"
  }
}

# サブネットの作成
resource "aws_subnet" "example_subnet" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"  # 適切なアベイラビリティゾーンに変更してください

  tags = {
    Name = "ExampleSubnet"
  }
}

# ルートテーブルアソシエーション
resource "aws_route_table_association" "example_route_table_assoc" {
  subnet_id      = aws_subnet.example_subnet.id
  route_table_id = aws_route_table.example_route_table.id
}

# セキュリティグループの作成
resource "aws_security_group" "example_sg" {
  vpc_id = aws_vpc.example_vpc.id

  # SSHアクセス許可
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPアクセス許可
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPSアクセス許可
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 全てのアウトバウンドアクセスを許可
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ExampleSG"
  }
}

# EC2インスタンスの作成
resource "aws_instance" "example_instance" {
  ami                    = "ami-00beae93a2d981137"  # Amazon Linux 2023 の x86_64用 AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.example_subnet.id
  vpc_security_group_ids = [aws_security_group.example_sg.id]
  key_name               = "default"  # 作成したキーペアの名前に変更してください
  associate_public_ip_address = true  # パブリックIPアドレスの割り当て

  tags = {
    Name = "ExampleInstance"
  }
}