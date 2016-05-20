#!/bin/sh
make html
rsync -avz _build/ icefox@roc.alopex.li:htdocs/temp/
echo "Done, you can view it at: https://alopex.li/temp/html/"
