
output public_a {
  value = aws_subnet.public_a
}

output allow_web {
  value = aws_security_group.allow_web 
}
