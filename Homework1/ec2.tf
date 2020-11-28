# Create the consul-servers
resource "aws_instance" "consul-servers" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.gen_key.key_name
  count                       = 3
  subnet_id                   = aws_subnet.homework-subnet.id
  associate_public_ip_address = "true"
  vpc_security_group_ids      = [aws_security_group.public-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  user_data                   = file("consul-server.sh")
  

  tags = {
    Name = "consul-server-${count.index + 1}"
    consul-server = "true"
  }
}

# Create the app-servers
resource "aws_instance" "app-servers" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.gen_key.key_name
  count                       = 1
  subnet_id                   = aws_subnet.homework-subnet.id
  associate_public_ip_address = "true"
  vpc_security_group_ids      = [aws_security_group.public-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  user_data                   = file("consul-agent.sh")

  tags = {
    Name = "app-server-${count.index + 1}"
  }
}

# Create keys for the instances
resource "tls_private_key" "gen_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "gen_key" {
  key_name   = "gen_key"
  public_key = tls_private_key.gen_key.public_key_openssh
}

resource "local_file" "gen_key" {
  sensitive_content = tls_private_key.gen_key.private_key_pem
  filename          = "gen_key.pem"
}

# Create an IAM role for the auto-join
resource "aws_iam_role" "consul-join" {
  name               = "opsschool-consul-join"
  assume_role_policy = file("${path.module}/templates/policies/assume-role.json")
}

# Create the policy
resource "aws_iam_policy" "consul-join" {
  name        = "opsschool-consul-join"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = file("${path.module}/templates/policies/describe-instances.json")
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul-join" {
  name       = "opsschool-consul-join"
  roles      = [aws_iam_role.consul-join.name]
  policy_arn = aws_iam_policy.consul-join.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul-join" {
  name  = "opsschool-consul-join"
  role = aws_iam_role.consul-join.name
}