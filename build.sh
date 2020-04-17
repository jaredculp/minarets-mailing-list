#!/bin/sh

rm page-*.html 2>/dev/null
awk -f parse.awk < minarets-mailbox.txt | csplit -s -f 'page-' - '/DOCTYPE/' '{99999}'
for f in page-*
do
  mv "$f" `echo "$f" | awk -F- '{printf("%s-%02d.html\n", $1, $2+1)}'`
done
