# /lib/X/Shell.pm の実装

perlの標準機能のみで実装してほしい。windows, mac, linuxで使えるように。

以下の関数を実装すること。

## which 

コマンドがあるかをチェックできる。拡張子に気をつけて

## sh 

コマンドを実行する。

$content = sh "cp -r",  $sample, "des";

戻り地が２つある場合は　$content, $code でエラーコードも返すこと。
