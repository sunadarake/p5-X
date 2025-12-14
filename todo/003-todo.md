# モジュールの追加の対応

linux、macの場合は utf8::all を　CPANから
windowsの場合は、　git@github.com:sunadarake/p5-win-unicode.git　をgihubからインストールしたい

cpanfileとMakefile.PLを書き直すこと。

そして
Xモジュール内で　

linux,macの場合は use utf8::all
windowsの場合は、use Win32::Unicode::Native をしたい。

use X; とした部分に効果が出るようにしてほしい。

このimport 処理は li/X.pm 内で記述するのがよいだろう。\\
