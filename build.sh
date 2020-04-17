#!/bin/sh

rm page-*.html 2>/dev/null
awk -f parse.awk < minarets-mailbox.txt > output
csplit -s -f 'page-' output '/DOCTYPE/' '{99999}'
for f in page-*
do
  mv "$f" "${f}.html"
done
rm output
