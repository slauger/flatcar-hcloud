# packer-hcloud-flatcar

Build Flatcar Container Linux Images on Hetzner Cloud with Hashicorp Packer.

## Required ENVs

  - `HCLOUD_TOKEN` - your personal hetzner api token

## Build Image

This builds an snapshot image in the hcloud for Flatcar Container Linux and injects the Hetzner Cloud Datasource (`http://169.254.169.254/hetzner/v1/userdata`).

```
packer build flatcar.json
```

## Example instance

You need to pass your Ignition Config via "user data". A Ignition Config can be generated by creating a Container Linux Config (YAML) and convert it to JSON via Container Linux Config Transpiler. Check the directory `examples/` for some example Container Linux Configs.

```
cat config.yaml | docker run --rm -i ghcr.io/flatcar-linux/ct:latest -platform
```