resource "aws_instance" "instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  subnet_id              = var.subnet_id
  user_data              = var.user_data
  vpc_security_group_ids = [var.security_group_id]
  key_name               = local.key_count == 0 ? "" : "bastion_key"
  private_ip             = var.private_ip == "" ? null : var.private_ip


  root_block_device {
    volume_size = var.volume_size
  }

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.name}-ec2-instance-${var.environment}" }
    )
  )
}

resource "aws_key_pair" "bastion_key_pair" {
  count      = local.key_count
  public_key = var.public_key
  key_name   = "bastion_key"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = var.name
  role = local.role_name
}

resource "aws_iam_role" "ec2_role" {
  count              = local.role_count
  name               = "${title(var.name)}EC2Role${title(var.environment)}"
  assume_role_policy = templatefile("${path.module}/templates/ec2_assume_role.json.tpl", { account_id = data.aws_caller_identity.current.id })
  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.name}-ec2-iam-role-${var.environment}" }
    )
  )
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = local.role_name
}

resource "aws_iam_role_policy_attachment" "ec2_variable_policy_attachment" {
  for_each   = var.attach_policies
  policy_arn = each.value
  role       = local.role_name
}
