data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_iam_role" "s3_role" {
  name = "s3_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
})

  tags = {
    tag-key = "s3-value"
  }
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.s3_role.name
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.s3_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "mydb"
  username             = "app"
  password             = "Test1234"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

data "template_file" "user_data" {
  template = file("user_data.sh")
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  user_data     = data.template_file.user_data.rendered
  iam_instance_profile = aws_iam_instance_profile.test_profile.name
  tags = {
    Name = "HelloWorld"
  }
  
}