resource "aws_iam_user" "data_scientist" {
  name = "data-scientist-user"
  tags = {
    Description = "Data Scientist user with SageMaker and S3 access"
  }
}

resource "aws_iam_user_policy_attachment" "sagemaker_full_access" {
  user       = aws_iam_user.data_scientist.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_user_policy_attachment" "s3_read_only" {
  user       = aws_iam_user.data_scientist.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
