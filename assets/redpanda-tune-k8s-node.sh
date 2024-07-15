#!/bin/sh
echo 'Finding latest Redpanda version'
export VERSION=$(curl -s 'https://hub.docker.com/v2/repositories/redpandadata/redpanda/tags/?ordering=last_updated&page=1&page_size=50' | jq -r '.results[].name' | grep -v "a*64" | sed -En "s/v(.*)/\1/p" | sort -V | tail -1)
echo "Downloading Redpanda version $VERSION"
curl -LO https://packages.vectorized.io/nzc4ZYQK3WRGd9sy/redpanda/deb/any-distro/pool/any-version/main/r/re/redpanda_$VERSION-1/redpanda_$VERSION-1_amd64.deb > /dev/null 2>&1
echo 'Installing Redpanda'
sudo dpkg -i redpanda_$VERSION-1_amd64.deb > /dev/null 2>&1
echo 'Tuning Redpanda'
sudo rpk redpanda mode production > /dev/null 2>&1
sudo rpk redpanda tune all > /dev/null 2>&1
#sudo rpk iotune
rm redpanda_$VERSION-1_amd64.deb