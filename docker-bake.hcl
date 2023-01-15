variable "TAG" {
  default = "latest"
}

group "default" {
  targets = [
    "main",
    // "other"
  ]
}

target "main" {
  dockerfile = "Dockerfile"
  platforms = [
    // "linux/amd64",
    "linux/arm64/v8",
    // "linux/arm64"
  ]
}

target "darwin" {
  dockerfile = "Dockerfile.darwin"
  platforms = [
    "darwin/amd64",
    "darwin/arm64"
  ]
}

target "other" {
  dockerfile = "Dockerfile.other"
  platforms = [
    "linux/386",
    "linux/arm/v6",
    "linux/arm/v7",
    "linux/arm64/v8",
    "linux/ppc64le",
    "linux/s390x"
  ]
}
