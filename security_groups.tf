resource "aws_security_group" "my_public_app_sg" {
    name = "my_public_app_sg"
    description = "Allow access to this server"
    vpc_id = data.aws_vpc.main_vpc.id

    # INBOUND CONNECTIONS
    ingress {
        description = "Allow SSH into the EC2"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Allow HTTP into the EC2"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # OUTBOUND CONNECTIONS
    egress {
        description = "Allow access to the world"
        from_port = 0
        to_port = 0
        protocol = "-1" # TCP + UDP
        cidr_blocks = ["0.0.0.0/0"]
    }  
}