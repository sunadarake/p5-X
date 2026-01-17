このXモジュールでは、Windows環境では、 Win32::Unicodeを内部で使っている。
t/06-file.t をテストすると、以下のエラーが出る。
これは日本語パスの時に適切に処理できていない。
lib\X\File.pm　の fg 関数で問題が発生している。
何が原因で解決をしてほしい。
参考文献として、　Win32_Unicode_API_doc.md　がある。

```
t\06-file.t ......
1..14
ok 9 - file exists before rm
ok 10 - file removed after rm
ok 11 - fp creates Japanese filename

#   Failed test 'fg reads Japanese file content'
not ok 12 - fg reads Japanese file content#   at t\06-file.t line 64.

Wide character in print at C:/Strawberry/perl/lib/Test2/Formatter/TAP.pm line 125.
#          got: undef
#     expected: '譌･譛ｬ隱槭さ繝ｳ繝・Φ繝・

#   Failed test 'ff finds files in Japanese directory'
not ok 13 - ff finds files in Japanese directory#   at t\06-file.t line 67.


#   Failed test 'rm removes Japanese filename'
#   at t\06-file.t line 70.
not ok 14 - rm removes Japanese filename
# Looks like you failed 3 tests of 14.
Dubious, test returned 3 (wstat 768, 0x300)
Failed 3/14 subtests

Test Summary Report
-------------------
t\06-file.t    (Wstat: 768 (exited 3) Tests: 14 Failed: 3)
  Failed tests:  12-14
  Non-zero exit status: 3
```
