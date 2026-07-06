variable "ecs_task_ip" {
  description = "Current ECS task public IP"
  type = string
}

resource "aws_cloudfront_distribution" "flask_api" {
  origin {
    domain_name = "${var.ecs_task_ip}.nip.io"
    origin_id   = "flask-app-origin"

    custom_origin_config {
      http_port              = 5000
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = ""

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "flask-app-origin"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "flask-app-cloudfront"
  }
}

output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.flask_api.domain_name}"
}