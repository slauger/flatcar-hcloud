data "http" "version" {
  url = "https://stable.release.flatcar-linux.net/amd64-usr/current/version.txt"
}

locals {
  // hacky way of reading the "env" formatted file as yaml
  flatcar_version_info = yamldecode(regex_replace(data.http.version.body, "=", ": "))
}
