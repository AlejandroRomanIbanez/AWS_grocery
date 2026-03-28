resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Using variables passed from the root "Brain"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.ec2_sg_id]

  # IAM profile
  iam_instance_profile = var.instance_profile_name

  # Template Injection - Pointing to the root scripts folder
  user_data = templatefile("${path.module}/../../scripts/docker_setup.tftpl", {
    db_endpoint    = var.db_endpoint,
    container_name = var.container_name,
    db_password    = var.db_password,
    s3_bucket_name = var.s3_bucket_id
  })

  tags = { Name = "grocerymate-ec2" }
}