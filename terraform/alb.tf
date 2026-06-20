# Public application load balancer that receives inbound traffic.
resource "aws_lb" "this" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
}

# HTTP listener with a standard 503 fixed response for unmatched paths.
# Microservices will register their own routing rules onto this listener.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Service Unavailable"
      status_code  = "503"
    }
  }
}

# HTTPS listener with a standard 503 fixed response, created if a certificate ARN is provided.
resource "aws_lb_listener" "https" {
  count             = var.acm_certificate_arn == null ? 0 : 1
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Service Unavailable"
      status_code  = "503"
    }
  }
}
