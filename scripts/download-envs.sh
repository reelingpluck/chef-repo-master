#!/bin/bash

# Script's own directory
# Stolen from stackoverflow
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pushd $DIR/../environments

for i in `knife environment list`; do 
  echo $i;
  knife environment show $i -Fj > $i.json
done;

popd
