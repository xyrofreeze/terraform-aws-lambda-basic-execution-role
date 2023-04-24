terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_role_discord_bot" {
  name = "destracker-iam-role-discord-bot"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  inline_policy {
    name = "destracker-iam-policy-discord-bot"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["ssm:GetParameter"]
          Effect   = "Allow"
          Resource = aws_ssm_parameter.parameter_discord_bot_token.arn
        },
      ]
    })
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.role.name
}
