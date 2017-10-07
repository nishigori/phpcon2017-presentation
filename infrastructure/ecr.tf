/*
 * Amazon ECR (EC2 Container Registry)
 *
 * https://aws.amazon.com/ecr/
 */

resource "aws_ecr_repository" "phpcon2017" {
  name = "phpcon2017-presentation"
}

resource "aws_ecr_repository_policy" "phpcon2017" {
  repository = "${aws_ecr_repository.phpcon2017.name}"
  policy     = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": ["ecr:*"]
        }
    ]
}
EOF
}
