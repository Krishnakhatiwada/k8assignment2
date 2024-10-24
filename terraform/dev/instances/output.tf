# Step 10 - Add output variables
output "eip_my_instance" {
  value = aws_eip.static_eip_my_instance.public_ip
}

# output "eip_my_instance1" {
#   value = aws_eip.static_eip_my_instance_1.public_ip
# }

# output "eip_my_instance2" {
#   value = aws_eip.static_eip_my_instance_2.public_ip
# }