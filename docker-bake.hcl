variable "TAG" {
  default = "latest"
}

group "default" {
  targets = [
    // "main",
    // "other",
    "darwin",
  ]
}

target "main" {
  dockerfile = "Dockerfile"
  platforms = [
    "linux/386",
    "linux/amd64",
    "linux/arm/v6",
    "linux/arm/v7",
    "linux/arm64",
    "linux/mips64",
    "linux/mips64le",
    "linux/ppc64le",
    "linux/s390x",
    "linux/riscv64",
  ]
}

target "darwin" {
  platforms = [
    // "darwin/amd64",
    "darwin/arm",
    "darwin/arm64",
  ]
}

target "other" {
  platforms = [
    // "linux/arm",
    // "linux/arm64/v8",
    "linux/mips",
    "linux/mipsle",
    "linux/ppc64",
  ]
}

target "android" {
  platforms = [
    "android/386",
    "android/amd64",
    "android/arm",
    "android/arm64",
  ]
}
