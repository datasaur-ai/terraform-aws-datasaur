output "bucket_name" {
  value = "${aws_s3_bucket.vulcan.id}"
}

output "bucket_arn" {
  value = "${aws_s3_bucket.vulcan.arn}"
}
