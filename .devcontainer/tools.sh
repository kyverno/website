#! /bin/bash

## Install Hugo Extended v0.119.0
wget https://github.com/gohugoio/hugo/releases/download/v0.119.0/hugo_extended_0.119.0_linux-amd64.tar.gz -O hugo.tar.gz && tar -xzf hugo.tar.gz hugo && sudo mv hugo /usr/bin/hugo && rm hugo.tar.gz