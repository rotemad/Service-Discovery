output "consul-servers" {
  value = aws_instance.consul-servers.*.public_ip
}
output "app" {
  value = aws_instance.app-servers.*.public_ip
}