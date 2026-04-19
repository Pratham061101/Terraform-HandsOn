output "aws_security_group_http_server_sg" {
  value = aws_security_group.aws_server_sg
}

output "aws_instance_ec2_instance" {
  value = aws_instance.http_server
}

output "aws_server_public_dns" {
  value = aws_instance.http_server.public_dns
}