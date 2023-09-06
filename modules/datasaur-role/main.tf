data "aws_caller_identity" "current" {}

resource "aws_iam_role" "datasaur_role" {
  name = "datasaur-app-${var.cluster_name}-role"
  path = "/datasaur/${var.cluster_name}/"
  max_session_duration = var.max_session_duration

  tags = {
    project     = var.project
    environment = var.environment
  }

  assume_role_policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Action" = "sts:AssumeRole",
        "Principal" = {
          "AWS" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Effect" = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "bucket_policy" {
  name = "datasaur-app-${var.cluster_name}-role-bucket-policy"
  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Action" = [
          "s3:ListBucket",
          "s3:ListBucketVersions",
          "s3:PutObject",
          "s3:GetObjectAcl",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:PutObjectAcl",
        ],
        "Effect"   = "Allow",
        "Resource" = concat(var.bucket_resources, formatlist("%s/*", var.bucket_resources))
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bucket_policy_attach" {
  role       = aws_iam_role.datasaur_role.name
  policy_arn = aws_iam_policy.bucket_policy.arn
}

resource "aws_iam_role_policy_attachment" "textract_policy_attach" {
  count      = var.use_textract ? 1 : 0
  role       = aws_iam_role.datasaur_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonTextractFullAccess"
}

resource "aws_iam_role_policy_attachment" "sagemaker_policy_attach" {
  count      = var.use_sagemaker ? 1 : 0
  role       = aws_iam_role.datasaur_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_role_policy" "external_bucket_policy" {
  count          = var.use_bucket_accessor ? 1 : 0
  name           = "external_bucket_policy"
  role           = aws_iam_role.datasaur_role.id

  policy         = jsonencode({
    Version      = "2012-10-17"
    Statement    = [
      {
        Action   = "sts:AssumeRole"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "sts:AssumeRole"
        Effect   = "Deny"
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
      }
    ]
  })
}
