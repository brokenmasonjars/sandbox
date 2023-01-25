#############################
##### Route53 Resources #####
#############################
data "aws_caller_identity" "current" {}

###########################
##### starkgovtech.com #####
###########################


##### Route53 Zone #####

resource "aws_route53_zone" "starkgovtech_rt53_zone" {
  name = "starkgovtech.com."
}


#### Secure DNS Config #####

resource "aws_kms_key" "starkgovtech_rt53_dnssec_kms" {
  customer_master_key_spec = "ECC_NIST_P256"
  deletion_window_in_days  = 7
  key_usage                = "SIGN_VERIFY"
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign",
        ],
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Sid      = "Allow Route 53 DNSSEC Service",
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:route53:::hostedzone/*"
          }
        }
      },
      {
        Action = "kms:CreateGrant",
        Effect = "Allow"
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Sid      = "Allow Route 53 DNSSEC Service to CreateGrant",
        Resource = "*"
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = "true"
          }
        }
      },
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
    ]
    Version = "2012-10-17"
  })
}

resource "aws_route53_key_signing_key" "starkgovtech_rt53_signing_key" {
  hosted_zone_id             = aws_route53_zone.starkgovtech_rt53_zone.id
  key_management_service_arn = aws_kms_key.starkgovtech_rt53_dnssec_kms.arn
  name                       = "example"
}

resource "aws_route53_hosted_zone_dnssec" "starkgovtech_rt53_dnssec" {
  depends_on = [
    aws_route53_key_signing_key.starkgovtech_rt53_signing_key
  ]
  hosted_zone_id = aws_route53_key_signing_key.starkgovtech_rt53_signing_key.hosted_zone_id
}


##### starkgovtech.com Zone Records #####


# resource "aws_route53_record" "starkgovtech_rt53_record_mx_1" {
#   zone = "starkgovtech.com."
#   ttl  = 3600

#   mx {
#     preference = 10
#     exchange   = "us-smtp-inbound-1.mimecast.com."
#   }

#   mx {
#     preference = 20
#     exchange   = "us-smtp-inbound-2.mimecast.com."
#   }
# }


resource "aws_route53_record" "starkgovtech_rt53_record_cname_1" {
  zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
  name    = "selector1._domainkey"
  type    = "CNAME"
  ttl     = "3600"
  records = ["selector1-starkgovtech-com._domainkey.usservicesinc.onmicrosoft.com"]
}

resource "aws_route53_record" "starkgovtech_rt53_record_cname_2" {
  zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
  name    = "selector2._domainkey"
  type    = "CNAME"
  ttl     = "3600"
  records = ["selector2-starkgovtech-com._domainkey.usservicesinc.onmicrosoft.com."]
}


resource "aws_route53_record" "starkgovtech_rt53_record_txt_1" {
  zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
  name    = "@"
  type    = "TXT"
  ttl     = "3600"
  records = ["MS=ms86658757","0ed1fe018aa27509affdbc41a6accaef86ea014e41","v=spf1 include:spf.protection.outlook.com include:us._netblocks.mimecast.com -all", "v=DMARC1; p=none; fo=1; rua=mailto:rua+starkgovtech.com@dmarc.barracudanetworks.com; ruf=mailto:ruf+starkgovtech.com@dmarc.barracudanetworks.com"]
}

# resource "aws_route53_record" "starkgovtech_rt53_record_txt_2" {
#   zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
#   name    = "@"
#   type    = "TXT"
#   ttl     = "3600"
#   records = ["0ed1fe018aa27509affdbc41a6accaef86ea014e41","v=spf1 include:spf.protection.outlook.com include:us._netblocks.mimecast.com -all", "v=DMARC1; p=none; fo=1; rua=mailto:rua+starkgovtech.com@dmarc.barracudanetworks.com; ruf=mailto:ruf+starkgovtech.com@dmarc.barracudanetworks.com"]
# }

# resource "aws_route53_record" "starkgovtech_rt53_record_txt_3" {
#   zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
#   name    = "@"
#   type    = "TXT"
#   ttl     = "3600"
#   records = ["v=spf1 include:spf.protection.outlook.com include:us._netblocks.mimecast.com -all"]
# }

# resource "aws_route53_record" "starkgovtech_rt53_record_txt_4" {
#   zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
#   name    = "_dmarc"
#   type    = "TXT"
#   ttl     = "3600"
#   records = ["v=DMARC1; p=none; fo=1; rua=mailto:rua+starkgovtech.com@dmarc.barracudanetworks.com; ruf=mailto:ruf+starkgovtech.com@dmarc.barracudanetworks.com"]
# }

resource "aws_route53_record" "starkgovtech_rt53_record_txt_5" {
  zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
  name    = "sentinel"
  type    = "TXT"
  ttl     = "3600"
  records = ["sentinel_id=zXG7X9cPJA"]
}

resource "aws_route53_record" "starkgovtech_rt53_record_txt_6" {
  zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
  name    = "mimecast20221028._domainkey"
  type    = "TXT"
  ttl     = "3600"
  records = ["v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCWTSYSiX5iAA7O2WqkBGqpORVrPw/MnPtgZ8SMkN1aX56FyM8jiFuEBRX7ZSOGI7jO6w4REiih+Uc88gu9WxT6vhNPpbsatlDnRgnLSZ5ptUn09dutoC7irmmcqHLYu6lcGBRQ57nK1vruVbJzI6D5aHA0H4VzZgPM3w2F0JSP9wIDAQAB"]
}













# #############################
# ##### Route53 Resources #####
# #############################


# ###########################
# ##### starkechgov.com #####
# ###########################


# ##### Route53 Zone #####

# resource "aws_route53_zone" "starkgovtech_rt53_zone" {
#   name = var.starkgovtech_cloud_rt53_zone_name
# }


# #### Secure DNS Config #####

# resource "aws_kms_key" "starkgovtech_rt53_dnssec_kms" {
#   customer_master_key_spec = "ECC_NIST_P256"
#   deletion_window_in_days  = 7
#   key_usage                = "SIGN_VERIFY"
#   policy = jsonencode({
#     Statement = [
#       {
#         Action = [
#           "kms:DescribeKey",
#           "kms:GetPublicKey",
#           "kms:Sign",
#         ],
#         Effect = "Allow"
#         Principal = {
#           Service = "dnssec-route53.amazonaws.com"
#         }
#         Sid      = "Allow Route 53 DNSSEC Service",
#         Resource = "*"
#         Condition = {
#           StringEquals = {
#             "aws:SourceAccount" = data.aws_caller_identity.current.account_id
#           }
#           ArnLike = {
#             "aws:SourceArn" = "arn:aws:route53:::hostedzone/*"
#           }
#         }
#       },
#       {
#         Action = "kms:CreateGrant",
#         Effect = "Allow"
#         Principal = {
#           Service = "dnssec-route53.amazonaws.com"
#         }
#         Sid      = "Allow Route 53 DNSSEC Service to CreateGrant",
#         Resource = "*"
#         Condition = {
#           Bool = {
#             "kms:GrantIsForAWSResource" = "true"
#           }
#         }
#       },
#       {
#         Action = "kms:*"
#         Effect = "Allow"
#         Principal = {
#           AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#         }
#         Resource = "*"
#         Sid      = "Enable IAM User Permissions"
#       },
#     ]
#     Version = "2012-10-17"
#   })
# }

# resource "aws_route53_key_signing_key" "starkgovtech_rt53_signing_key" {
#   hosted_zone_id             = aws_route53_zone.starkgovtech_rt53_zone.id
#   key_management_service_arn = aws_kms_key.starkgovtech_rt53_dnssec_kms.arn
#   name                       = "example"
# }

# resource "aws_route53_hosted_zone_dnssec" "starkgovtech_rt53_dnssec" {
#   depends_on = [
#     aws_route53_key_signing_key.starkgovtech_rt53_signing_key
#   ]
#   hosted_zone_id = aws_route53_key_signing_key.starkgovtech_rt53_signing_key.hosted_zone_id
# }


# ##### starkgovtech.com Zone Records #####

# resource "aws_route53_record" "starkgovtech_rt53_record_ns_1" {
#   zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
#   name    = "@"
#   type    = "NS"
#   ttl     = "3600"
#   records = "dns1.registrar-servers.com."
# }

# resource "aws_route53_record" "starkgovtech_rt53_record_ns_2" {
#   zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
#   name    = "@"
#   type    = "NS"
#   ttl     = "3600"
#   records = "dns2.registrar-servers.com."
# }

# resource "aws_route53_record" "starkgovtech_rt53_record_mx_2" {
#   zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
#   name    = "@"
#   type    = "MX"
#   ttl     = "3600"
#   records = "us-smtp-inbound-1.mimecast.com."
# }

# resource "aws_route53_record" "starkgovtech_rt53_record_mx_2" {
#   zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
#   name    = "@"
#   type    = "MX"
#   ttl     = "3600"
#   records = "us-smtp-inbound-2.mimecast.com."
# }

# resource "aws_route53_record" "starkgovtech_rt53_record_mx_2" {
#   zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
#   name    = "@"
#   type    = "MX"
#   ttl     = "3600"
#   records = "us-smtp-inbound-2.mimecast.com."
# }

# resource "aws_route53_record" "starkgovtech_rt53_record_cname_1" {
#   zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
#   name    = "selector1._domainkey"
#   type    = "CNAME"
#   ttl     = "3600"
#   records = "selector1-starkgovtech-com._domainkey.usservicesinc.onmicrosoft.com"
# }

# resource "aws_route53_record" "starkgovtech_rt53_record_cname_2" {
#   zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
#   name    = "selector2._domainkey"
#   type    = "CNAME"
#   ttl     = "3600"
#   records = "selector2-starkgovtech-com._domainkey.usservicesinc.onmicrosoft.com."
# }


# resource "aws_route53_record" "starkgovtech_rt53_record_txt_1" {
#   zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
#   name    = "@"
#   type    = "TXT"
#   ttl     = "3600"
#   records = "MS=ms86658757"
# }

# resource "aws_route53_record" "starkgovtech_rt53_record_txt_2" {
#   zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
#   name    = "@"
#   type    = "TXT"
#   ttl     = "3600"
#   records = "0ed1fe018aa27509affdbc41a6accaef86ea014e41"
# }

# resource "aws_route53_record" "starkgovtech_rt53_record_txt_3" {
#   zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
#   name    = "@"
#   type    = "TXT"
#   ttl     = "3600"
#   records = "v=spf1 include:spf.protection.outlook.com include:us._netblocks.mimecast.com -all"
# }

# resource "aws_route53_record" "starkgovtech_rt53_record_txt_4" {
#   zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
#   name    = "_dmarc"
#   type    = "TXT"
#   ttl     = "3600"
#   records = "v=DMARC1; p=none; fo=1; rua=mailto:rua+starkgovtech.com@dmarc.barracudanetworks.com; ruf=mailto:ruf+starkgovtech.com@dmarc.barracudanetworks.com"
# }

# resource "aws_route53_record" "starkgovtech_rt53_record_txt_5" {
#   zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
#   name    = "sentinel"
#   type    = "TXT"
#   ttl     = "3600"
#   records = "sentinel_id=zXG7X9cPJA"
# }

# resource "aws_route53_record" "starkgovtech_rt53_record_txt_6" {
#   zone_id = aws_route53_zone.starkgovtech_rt53_zone.zone_id
#   name    = "mimecast20221028._domainkey"
#   type    = "TXT"
#   ttl     = "3600"
#   records = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCWTSYSiX5iAA7O2WqkBGqpORVrPw/MnPtgZ8SMkN1aX56FyM8jiFuEBRX7ZSOGI7jO6w4REiih+Uc88gu9WxT6vhNPpbsatlDnRgnLSZ5ptUn09dutoC7irmmcqHLYu6lcGBRQ57nK1vruVbJzI6D5aHA0H4VzZgPM3w2F0JSP9wIDAQAB"
# }