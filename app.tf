resource "aws_instance" "NodeJSapp" {
  ami           = "${lookup(var.AmiLinux, var.region)}"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.PublicAZA.id}"
  vpc_security_group_ids = ["${aws_security_group.FrontEnd.id}"]
  key_name = "${var.key_name}"
  tags {
        Name = "NodeJSapp"
  }
  user_data = <<SampleDoc
  #!/bin/bash
  yum update -y
  yum install -y httpd24 nodejs docker git
  service httpd start
  sudo service docker start
  sudo usermod -a -G docker ec2-user

  connection {
    user = "ubuntu"
    key_file = "ssh/key"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update",
      "sudo yum install apt-transport-https ca-certificates",
      "git clone https://github.com/ShoppinPal/loopback-mongo-sandbox.git",
      "sudo yum update",
      "sudo yum install -y docker-engine=1.12.0-0~trusty",
      "sudo docker swarm init",
      "sudo docker swarm join-token --quiet worker > /home/ubuntu/token"
    ]
  }
  provisioner "file" {
    source = "loopback-mongo-sandbox"
    destination = "/home/ubuntu/"
  }
  tags = { 
    Name = "swarm-master"
  
 }
SampleDoc
}

resource "aws_instance" "database" {
  ami           = "${lookup(var.AmiLinux, var.region)}"
  instance_type = "t2.micro"
  associate_public_ip_address = "false"
  subnet_id = "${aws_subnet.PrivateAZA.id}"
  vpc_security_group_ids = ["${aws_security_group.Database.id}"]
  key_name = "${var.key_name}"
  tags {
        Name = "database"
  }
  user_data = <<SampleDoc
  #!/bin/bash
  yum update -y
  yum install -y mongodb-org 
  service mongod start
  sudo chkconfig mongod on
SampleDoc
}

