このXモジュールでは、Windows環境では、 Win32::Unicodeを内部で使っている。
これを使うことで、Windows環境でUnicode対応の関数を使うことができる。　(参考に Win32_Unicode_API_doc.md を見ること。)

今回は、文字化け関連の問題が発生している。

試しにWin32::Unicode で試してみる。正常に　オレオレ　というディレクトリが作成される。

```perl
use utf8;
use Win32::Unicode::Dir;

mkpathW("オレオレ");
```

そして、 Xモジュールで試すと文字化けしてしまう。


```perl
use utf8;
use X;

md("オレオレ");
```

何が問題だと思う？
