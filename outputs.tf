output "vpc_id" { value = aws_vpc.lab_vpc.id }
output "public_subnet_id_1" { value = aws_subnet.lab_public_subnet1.id }
output "public_subnet_id_2" { value = aws_subnet.lab_public_subnet2.id }
output "private_subnet_id_1" { value = aws_subnet.lab_private_subnet1.id }
output "private_subnet_id_2" { value = aws_subnet.lab_private_subnet2.id }
output "public_route_table_id" { value = aws_route_table.public_route_table.id }
output "private_route_table_id" { value = aws_route_table.private_route_table.id }
output "web_security_group_id" {
  value       = aws_security_group.web_sg.id
  description = "ID del Security Group para HTTP (Web Security Group)"
}
output "web1_public_ip" {
  value       = aws_instance.web1.public_ip
  description = "IP pública de la EC2 web1"
}

output "web1_private_ip" {
  value       = aws_instance.web1.private_ip
  description = "IP privada de la EC2 web1"
}

output "web1_url" {
  value       = "http://${aws_instance.web1.public_ip}/"
  description = "URL HTTP de la EC2 web1 (requiere IGW para ser accesible desde Internet)"
}
