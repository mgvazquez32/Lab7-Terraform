# Lab 7 – Terraform VPC + EC2

Este laboratorio implementa infraestructura básica en **AWS** usando **Terraform**.  
Se crea una red con VPC, subredes públicas y privadas, tablas de ruteo, Internet Gateway, NAT Gateway, un Security Group y una instancia EC2 con Apache + PHP.

---

## 📌 Recursos creados

1. **VPC**
   - CIDR: `10.0.0.0/16`
   - Nombre: `lab-vpc`

2. **Subnets**
   - Pública 1 → `10.0.0.0/24` (us-east-1a)
   - Pública 2 → `10.0.2.0/24` (us-east-1a)
   - Privada 1 → `10.0.1.0/24` (us-east-1a)
   - Privada 2 → `10.0.3.0/24` (us-east-1a)

3. **Internet Gateway**
   - Nombre: `lab-igw`

4. **NAT Gateway**
   - Con Elastic IP asignada
   - Nombre: `lab-nat-public1-us-east-1a`

5. **Route Tables**
   - Pública → con salida a IGW
   - Privada → con salida a NAT Gateway

6. **Security Group**
   - Nombre: `web-security-group`
   - Regla Inbound:
     - HTTP (80) abierto a `0.0.0.0/0`
   - Regla Outbound:
     - Todo permitido (`0.0.0.0/0`)

7. **Instancia EC2**
   - AMI: Amazon Linux 2
   - Tipo: `t2.micro`
   - Subnet: `Public Subnet 2`
   - Auto-assign Public IP: habilitado
   - Tags:
     - `EC2-LAB = Web Server 1`
     - `Name = web1`
   - Security Group: `web-security-group`
   - User data (bootstrap):
     ```bash
     #!/bin/bash
     yum install -y httpd mysql php
     wget https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-100-ACCLFO-2-102668/2-lab2-vpc/s3/lab-app.zip
     unzip lab-app.zip -d /var/www/html/
     chkconfig httpd on
     service httpd start
     ```

---

## 📂 Archivos

- `main.tf` → definición de recursos (VPC, subnets, SG, EC2, etc.)
- `providers.tf` → configuración del provider AWS
- `versions.tf` → versión requerida de Terraform y AWS provider
- `variables.tf` → variables de entrada
- `outputs.tf` → exporta IDs de VPC, subnets, tablas de ruteo, IP de la instancia, URL pública
- `.gitignore` → excluye `.terraform/`, `*.tfstate`, `*.tfplan`, credenciales

---

## ▶️ Ejecución

1. Inicializar el directorio:
   ```bash
   terraform init -upgrade
