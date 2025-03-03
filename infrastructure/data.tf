# Fetch public IP dynamically if manual_ip is set to "auto" (force IPv4)
data "external" "my_ip" {
  count = var.manual_ip == "auto" ? 1 : 0

  program = ["bash", "-c", <<EOT
  ip=$(curl -s -4 ifconfig.me || echo 'error');
  if [ "$ip" != "error" ]; then
    echo "{\"ip\": \"$ip\"}";
  else
    echo "{\"error\": \"failed to fetch IP\"}";
  fi
  EOT
  ]
}

# Fetch S3 pre-signed URL for an object in grocerymate-terraform-state
# Note: This resource is unused in your provided main.tf or other files. Remove if not needed.
# data "external" "s3_presigned_url" {
#   program = ["bash", "-c", <<EOT
#     url=$(aws s3 presign s3://grocerymate-terraform-state/example-file.txt --expires-in 3600 2>/dev/null || echo 'error')
#     if [ "$url" != "error" ]; then
#       echo "{\"url\": \"$url\"}"
#     else
#       echo "{\"error\": \"Failed to generate pre-signed URL\"}"
#     fi
#   EOT
#   ]
# }