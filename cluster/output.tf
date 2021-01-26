output "web_ids" {
  description = "List of IDs of was instances"
  value       = aws_instance.web.*.id
}
output "was_ids" {
  description = "List of IDs of web instances"
  value       = aws_instance.was.*.id
}
output "dbs_ids" {
  description = "List of IDs of db instances"
  value       = aws_instance.db.*.id
}
output "web_ips" {
  description = "List of IDs of was instances"
  value       = aws_instance.web.*.public_ip
}
output "was_ips" {
  description = "List of IDs of web instances"
  value       = aws_instance.was.*.public_ip
}
output "dbs_ips" {
  description = "List of IDs of db instances"
  value       = aws_instance.db.*.public_ip
}