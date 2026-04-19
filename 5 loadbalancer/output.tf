output "aws_security_group_http_server_sg" {
  value = aws_security_group.aws_server_sg
}

output "aws_instance_ec2_instance" {
  value = aws_instance.http_servers
}

output "aws_server_public_dns" {
  value = values(aws_instance.http_servers).*.id
}

output "elb_public_dns" {
  value = aws_elb.elb
}