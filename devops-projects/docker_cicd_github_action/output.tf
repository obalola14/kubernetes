output "public_ip"{
    value = aws_instance.github_instance.public_ip
}