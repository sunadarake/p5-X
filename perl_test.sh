#!/bin/sh
# perlのテストをする

if [ $# != 0 ]; then
  t="$1"
else
  t="t/"
fi

prove -v -Ilib/ -Ilocal/lib/perl5 "$t"
