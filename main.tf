provider "aws" {
  version = "~> 3.0"
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_vpc" "vpc_example_network" {

  cidr_block="10.10.0.0/26"
}

resource "aws_subnet" "web" {
  vpc_id     = aws_vpc.vpc_example_network.id
  cidr_block = "10.10.0.0/28"
  tags = {
    Name = "web"
  }
}

resource "aws_security_group" "allow_http" {
  vpc_id = aws_vpc.vpc_example_network.id
  name="allow_http"
  ingress {
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol   = "tcp"
    from_port  = 22
    to_port    = 22
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    protocol   = "tcp"
    from_port  = 0
    to_port    = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }


}


resource "aws_internet_gateway" "My_web_GW" {
 vpc_id = aws_vpc.vpc_example_network.id
 tags = {
        Name = "webGW"
  }
}

resource "aws_route_table" "My_web_route_table" {
 vpc_id = aws_vpc.vpc_example_network.id
 tags = {
        Name = "webRT"
 }
}


resource "aws_route" "My_web_inet" {
  route_table_id         = aws_route_table.My_web_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.My_web_GW.id
} 


resource "aws_route_table_association" "My_web_association" {
  subnet_id      = aws_subnet.web.id
  route_table_id = aws_route_table.My_web_route_table.id
} 

resource "aws_instance" "web1" {
  ami           = "ami-0885b1f6bd170450c"
  instance_type = "t2.micro"
  key_name= var.key_name
  associate_public_ip_address=true
  subnet_id=aws_subnet.web.id
    vpc_security_group_ids = [
         aws_security_group.allow_http.id,
  ]
  tags = {
    Name = "Instance#1"
  }
}

resource "aws_instance" "web2" {
  ami           = "ami-0885b1f6bd170450c"
  instance_type = "t2.micro"
  key_name= var.key_name
  associate_public_ip_address=true
  subnet_id=aws_subnet.web.id
    vpc_security_group_ids = [
         aws_security_group.allow_http.id,
  ]
  tags = {
    Name = "Instance#2"
  }
}



