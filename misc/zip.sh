#!/usr/bin/env bash
set -eux
: ' MULTILINE COMMENT

Zip everything into lambda.zip so you can upload it to AWS.

'
dir=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
cd "${dir}"
cd ..
rm -rf dist lambda.zip
mkdir -p dist
cp index.js package.json dist
cd dist
npm i --production
zip -qr ../lambda.zip  index.js node_modules
