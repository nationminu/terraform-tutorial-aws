output "web" {
  description = "ID of web instances"
  value       = aws_instance.web.id
}
output "db" {
  description = "ID of db instances"
  value       = aws_instance.db.id
}
output "web_ip" {
  description = "ID of web instances"
  value       = aws_instance.web.public_ip
}
output "db_ip" {
  description = "ID of db instances"
  value       = aws_instance.db.public_ip
}
output "web_pip" {
  description = "ID of web instances"
  value       = aws_instance.web.private_ip
}
output "db_pip" {
  description = "ID of db instances"
  value       = aws_instance.db.private_ip
}