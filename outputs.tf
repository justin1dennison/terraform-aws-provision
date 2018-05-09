output "Web Instance" {
  value = "${aws_instance.web.id}"
}

output "Web Instance IP" {
  value = ["${aws_instance.web.*.public_ip}"]
}
