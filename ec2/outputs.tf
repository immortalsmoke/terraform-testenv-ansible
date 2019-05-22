output "Public IPs - Ubuntu" {
	value = "${aws_instance.ansible-test-ubuntu-001.*.public_ip}"
}
output "Public IPs - Centos" {
	value = "${aws_instance.ansible-test-centos-001.*.public_ip}"
}

output "Public Subnets" {
	value = "${module.vpc.public_subnets}"
}

output "Public Key PEM" {
  value = "${tls_private_key.ansible-test-keys.public_key_pem}"
}

output "Private Key PEM" {
	value = "${tls_private_key.ansible-test-keys.private_key_pem}"
}

