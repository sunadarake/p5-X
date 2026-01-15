# perlのテストをする

param(
    [string]$t = "t/"
)

prove -v -Ilib/ -Ilocal/lib/perl5 $t
