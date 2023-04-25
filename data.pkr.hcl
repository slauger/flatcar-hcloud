data "http" "version" {
  url = "https://stable.release.flatcar-linux.net/${var.arch}-usr/current/version.txt"
}

locals {
  // hacky way of reading the "env" formatted file as yaml
  flatcar_version_info = yamldecode(regex_replace(data.http.version.body, "=", ": "))

  // dynamically calculate a server type based on arch
  server_type = var.server_type == "auto" ? (var.arch == "amd64" ? "cx11" : "cax11") : var.server_type
}
