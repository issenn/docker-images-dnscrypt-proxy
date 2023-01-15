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
    "linux/amd64",
    "linux/arm64",
    "darwin/amd64",
    "linux/386",
    "linux/arm/v6",
    "linux/arm/v7",
    "linux/ppc64le",
    "linux/s390x",
    "linux/riscv64",
    "linux/mips64le",
    "linux/mips64"
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
  platforms = [
    "linux/arm64/v8",
  ]
}
