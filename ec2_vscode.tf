provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "%HOME%/.aws/credentials"
}

terraform {
  backend "s3" {
    bucket = "tf-state-31122020"
    key    = "terraform/aws/ec2/xxxNNN/terraform.tfstate"
    region = "us-east-1"
  }
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

variable "ami_key_pair_name" {}

resource "aws_iam_policy" "dev-policy" {
  name        = "dev-policy"
  description = "TF general policy for hobby projects"
  policy      = file("devpolicy.json")
}

resource "aws_iam_role" "dev_access_role" {
  name               = "dev-role"
  description        = "TF Dev role"
  assume_role_policy = file("assumerolepolicy.json")
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.dev_access_role.name
  policy_arn = aws_iam_policy.dev-policy.arn
}

resource "aws_iam_instance_profile" "dev_profile" {
  name = "dev_profile"
  role = aws_iam_role.dev_access_role.name
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow inbound traffice from my laptop"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vs-code" {
  ami                  = "ami-0affd4508a5d2481b"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.dev_profile.name
  key_name             = var.ami_key_pair_name
  user_data            = file("provision.sh")
}

resource "null_resource" "vs-code" {
  connection {
    host = aws_instance.vs-code.public_ip
  }
  provisioner "local-exec" {
    command     = "bash ./update_ssh.sh ${aws_instance.vs-code.public_ip}"
  }
}

resource "aws_cloudwatch_metric_alarm" "idle" {
  alarm_name = "stop-idle-instance"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  comparison_operator = "LessThanThreshold"
  threshold = "2"
  evaluation_periods = "5"
  alarm_description = "Monitor for idle agent"
  insufficient_data_actions = []
  alarm_actions = ["arn:aws:automate:us-east-1:ec2:stop"]
  dimensions = {
    InstanceId = aws_instance.vs-code.id
  }
}
output "public_ip" {
  value = aws_instance.vs-code.public_ip
}
