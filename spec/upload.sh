#!/bin/sh
make html
rsync -avz _build/ icefox@roc.alopex.li:htdocs/temp/
