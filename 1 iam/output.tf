output "iam_user_details" {
    value = aws_iam_user.my_iam_user
}

output "s3_details" {
    value = aws_s3_bucket.my_s3_bucket
}
