#!/usr/bin/env sh

zcat $1 | awk '$0~/^#/ {print}' > $2
zcat $1 | awk '$0!~/#/ && $7~/PASS/ {print}' >> $2
