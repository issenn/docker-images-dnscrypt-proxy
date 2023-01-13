target "default" {
  dockerfile = "Dockerfile"
  context = "."
  platforms = [
    "linux/amd64"
  ]
}
