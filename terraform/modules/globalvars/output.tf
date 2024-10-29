# Default tags
output "default_tags" {
  value = {
    "Owner" = "Kubernetes"
    "App"   = "Web"
    "Project" = "assignment2"
  }
}

# Prefix to identify resources
output "prefix" {
  value = "assignment2" //changed here to push 2nd time
}