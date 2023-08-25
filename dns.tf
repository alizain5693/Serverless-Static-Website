resource "aws_route53_zone" "main" {
  name = "${var.domainName}"
}

resource "aws_route53_record" "res" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name = "${var.domainName}"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
    zone_id = "${aws_cloudfront_distribution.s3_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}


output "name_servers"{
    value = aws_route53_zone.main.name_servers
}