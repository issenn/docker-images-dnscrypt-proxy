variable "TAG" {
  default = "latest"
}

variable "DOCKER_BUILDKIT" {
  default = true
}

variable "BUILDKIT_PROGRESS" {
  default = "auto"
}

variable "PACKAGE_VERSION" {
  default = "0.0.0"
}

variable "PACKAGE_VERSION_PREFIX" {
  default = null
}

variable "PACKAGE_HEAD" {
  default = false
}

variable "GO111MODULE" {
  default = "on"
}

variable "GOPROXY" {
  default = "https://proxy.golang.org,direct,direct"
}

variable "GOPROXY_CN" {
  default = "https://goproxy.cn,https://proxy.golang.com.cn,https://mirrors.aliyun.com/goproxy/,https://athens.azurefd.net,direct"
}

variable "CGO_ENABLED" {
  default = 0
}

variable "BUILD_FLAGS" {
  default = "-v"
}

group "default" {
  targets = [
    "main",
    "other",
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
  args = {
    PACKAGE_NAME = "dnscrypt-proxy"
    PACKAGE_VERSION = "2.1.2"
    PACKAGE_VERSION_PREFIX = PACKAGE_VERSION_PREFIX
    PACKAGE_URL = "https://github.com/DNSCrypt/dnscrypt-proxy"
    PACKAGE_SOURCE_URL = "https://github.com/DNSCrypt/dnscrypt-proxy/archive/2.1.2.tar.gz"
    PACKAGE_HEAD_URL = "https://github.com/DNSCrypt/dnscrypt-proxy.git"
    PACKAGE_HEAD = PACKAGE_HEAD
    GO111MODULE = GO111MODULE
    GOPROXY = GOPROXY
    CGO_ENABLED = CGO_ENABLED
    BUILD_FLAGS = BUILD_FLAGS
  }
}

target "darwin" {
  platforms = [
    "darwin/amd64",
    // "darwin/arm",
    "darwin/arm64",
  ]
  args = {
    PACKAGE_NAME = "dnscrypt-proxy"
    PACKAGE_VERSION = "2.1.2"
    PACKAGE_VERSION_PREFIX = PACKAGE_VERSION_PREFIX
    PACKAGE_URL = "https://github.com/DNSCrypt/dnscrypt-proxy"
    PACKAGE_SOURCE_URL = "https://github.com/DNSCrypt/dnscrypt-proxy/archive/2.1.2.tar.gz"
    PACKAGE_HEAD_URL = "https://github.com/DNSCrypt/dnscrypt-proxy.git"
    PACKAGE_HEAD = PACKAGE_HEAD
    GO111MODULE = GO111MODULE
    GOPROXY = GOPROXY
    CGO_ENABLED = CGO_ENABLED
    BUILD_FLAGS = BUILD_FLAGS
  }
}

target "other" {
  platforms = [
    // "linux/arm",
    // "linux/arm64/v8",
    "linux/mips",
    "linux/mipsle",
    "linux/ppc64",
  ]
  args = {
    PACKAGE_NAME = "dnscrypt-proxy"
    PACKAGE_VERSION = "2.1.2"
    PACKAGE_VERSION_PREFIX = PACKAGE_VERSION_PREFIX
    PACKAGE_URL = "https://github.com/DNSCrypt/dnscrypt-proxy"
    PACKAGE_SOURCE_URL = "https://github.com/DNSCrypt/dnscrypt-proxy/archive/2.1.2.tar.gz"
    PACKAGE_HEAD_URL = "https://github.com/DNSCrypt/dnscrypt-proxy.git"
    PACKAGE_HEAD = PACKAGE_HEAD
    GO111MODULE = GO111MODULE
    GOPROXY = GOPROXY
    CGO_ENABLED = CGO_ENABLED
    BUILD_FLAGS = BUILD_FLAGS
  }
}

target "android" {
  platforms = [
    "android/386",
    "android/amd64",
    "android/arm",
    "android/arm64",
  ]
}
