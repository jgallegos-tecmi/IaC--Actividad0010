# main.tf
# Archivo Principal de Arranque.

###############################################################################
#
# Programador: Jorge Aureliano Gallegos Esparza.
#
# Fecha Inicio: 18-oct-2024.
# Última Modificación: 23-oct-2024.
#
###############################################################################

# Proveedor con el que Trabajaremos.
provider "aws" {
    access_key = var.AWS_Key
    secret_key = var.AWS_Secret
    region = var.Region_AWS
}

# Creamos la VPC.
resource "aws_vpc" "VPC010" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC-Actividad-010"
  }
}

# Crear SubRedPública 01.
resource "aws_subnet" "SubRedPub01" {
  vpc_id = aws_vpc.VPC010.id
  cidr_block = "10.0.0.0/20"
  availability_zone = "us-east-1a"
  tags = {
    Name = "SubRedPublica_01"
  }
}

# Crear SubRedPública 02.
resource "aws_subnet" "SubRedPub02" {
  vpc_id = aws_vpc.VPC010.id
  cidr_block = "10.0.16.0/20"
  availability_zone = "us-east-1b"
  tags = {
    Name = "SubRedPublica_02"
  }
}

# Crear SubRedPrivada 01.
resource "aws_subnet" "SubRedPriv01" {
  vpc_id = aws_vpc.VPC010.id
  cidr_block = "10.0.128.0/20"
  availability_zone = "us-east-1a"
  tags = {
    Name = "SubRedPrivada_01"
  }
}


# Crear SubRedPrivada 02.
resource "aws_subnet" "SubRedPriv02" {
  vpc_id = aws_vpc.VPC010.id
  cidr_block = "10.0.144.0/20"
  availability_zone = "us-east-1b"
  tags = {
    Name = "SubRedPrivada_02"
  }
}

# Crear InternetGateWay.
resource "aws_internet_gateway" "InternetGateWay" {
  vpc_id = aws_vpc.VPC010.id
  tags = {
    Name = "InternetGatewayPrincipal"
  }
}

# Creamos la Tabla de Ruteo.
resource "aws_route_table" "TablaRuteo" {
  vpc_id = aws_vpc.VPC010.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.InternetGateWay.id
  }
  tags = {
    Name = "Tabla de Ruteo Predeterminada."
  }
}

# Asociamos las Tablas de Ruteo a la SubRedPúblicaA
resource "aws_route_table_association" "AsociacionTRSRPubA" {
  subnet_id      = aws_subnet.SubRedPub01.id
  route_table_id = aws_route_table.TablaRuteo.id
}

# Asociamos las Tablas de Ruteo a la SubRedPúblicaB
resource "aws_route_table_association" "AsociacionTRSRPubB" {
  subnet_id      = aws_subnet.SubRedPub02.id
  route_table_id = aws_route_table.TablaRuteo.id
}

# Asociamos las Tablas de Ruteo a la SubRedPrivadaA
resource "aws_route_table_association" "AsociacionTRSRPrivA" {
  subnet_id      = aws_subnet.SubRedPriv01.id
  route_table_id = aws_route_table.TablaRuteo.id
}

# Asociamos las Tablas de Ruteo a la SubRedPrivadaB
resource "aws_route_table_association" "AsociacionTRSRPrivB" {
  subnet_id      = aws_subnet.SubRedPriv02.id
  route_table_id = aws_route_table.TablaRuteo.id
}

# Establecemos los Grupos de Seguridad
resource "aws_security_group" "SG-VPC010" {
  vpc_id = aws_vpc.VPC010.id
  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # RDP
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Permitir_SSH_HTTP_RDP"
  }
}

# Par de LLaves
resource "aws_key_pair" "AWSLLaves" {
  key_name   = "AWSLLaves"
  public_key = file("C:/Users/TecMilenio/.ssh/id_rsa.pub")
}

# Instancia EC2 (Ubuntu)
resource "aws_instance" "InstanciaUbuntu" {
  # Ubuntu 20.04 AMI
  ami           = "ami-0866a3c8686eaeeba" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.SubRedPub01.id
  vpc_security_group_ids = [aws_security_group.SG-VPC010.id]
  key_name      = aws_key_pair.AWSLLaves.key_name
  associate_public_ip_address = true
  tags = {
    Name = "InstanciaUbuntu"
  }
} 

# Instancia EC2 (Windows Server)
resource "aws_instance" "InstanciaWindows" {
  # Windows Server AMI 
  ami           = "ami-0324a83b82023f0b3" 
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.SubRedPub02.id
  vpc_security_group_ids = [aws_security_group.SG-VPC010.id]
  key_name      = aws_key_pair.AWSLLaves.key_name
  associate_public_ip_address = true
  tags = {
    Name = "InstanciaWindows"
  }
}

# Output para la IP pública de la instancia Ubuntu
output "IPPublicaUbuntu" {
  value = aws_instance.InstanciaUbuntu.public_ip
  description = "La dirección IP pública de la instancia Ubuntu"
}

# Output para la IP privada de la instancia Ubuntu
output "IPPrivadaUbuntu" {
  value = aws_instance.InstanciaUbuntu.private_ip
  description = "La dirección IP privada de la instancia Ubuntu"
}

# Output para la IP pública de la instancia Windows
output "IPPublicaWindows" {
  value = aws_instance.InstanciaWindows.public_ip
  description = "La dirección IP pública de la instancia Windows"
}

# Output para la IP privada de la instancia Windows
output "IPPrivadaWindows" {
  value = aws_instance.InstanciaWindows.private_ip
  description = "La dirección IP privada de la instancia Windows"
}

# Output para la ID de  instancia Ubuntu
output "IDUbuntu" {
  value = aws_instance.InstanciaUbuntu.id
  description = "ID de la instancia Ubuntu"
}

# Output para la IP pública de la instancia Windows
output "IDWindows" {
  value = aws_instance.InstanciaWindows.id
  description = "ID de la instancia Windows"
}
