resource "aws_instance" "my_public_server" {
  #count         = var.number_of_instances
  ami                    = data.aws_ami.aws_basic_linux.id
  instance_type          = var.ec2_type
  subnet_id              = data.aws_subnet.pubic.id
  vpc_security_group_ids = [aws_security_group.my_public_app_sg.id]
  key_name               = var.my_keypair
  iam_instance_profile   = aws_iam_instance_profile.dashboard_server_profile.id
  user_data              = file("user-data.sh")

    tags = {
    Name = "public_server"
  }
}

resource "aws_instance" "my_private_server" {
  count                  = var.number_of_private_instances
  ami                    = data.aws_ami.aws_basic_linux.id
  instance_type          = var.ec2_type
  subnet_id              = data.aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.my_private_app_sg.id]
  key_name               = var.my_keypair

  tags = {
    Name = "private_server_${count.index + 1}"
  }
}