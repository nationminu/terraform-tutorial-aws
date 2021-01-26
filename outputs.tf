output "id" {
  description = "IDs of instances"
  value       = aws_instance.ec2.*.id
} 
output "public_ips" {
  description = "List of public_ip of was instances"
  value       = aws_instance.ec2.*.public_ip
}
output "private_ips" {
  description = "List of private_ip of web instances"
  value       = aws_instance.ec2.*.private_ip
} 