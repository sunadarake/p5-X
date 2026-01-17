# Win32::Unicode API ドキュメント

Win32::Unicodeライブラリで定義されている関数の一覧です。

## Win32::Unicode::Console

コンソール出力関連の関数。

### エクスポート関数

- `printW([$fh,] @args)` - 標準出力またはファイルハンドルへUnicode文字列を出力
- `printfW([$fh,] $format, @args)` - フォーマットされたUnicode文字列を標準出力またはファイルハンドルへ出力
- `sayW([$fh,] @args)` - 改行付きでUnicode文字列を標準出力またはファイルハンドルへ出力
- `warnW(@args)` - 標準エラー出力へUnicode警告メッセージを出力
- `dieW(@args)` - 標準エラー出力へUnicodeエラーメッセージを出力してプログラム終了

## Win32::Unicode::Dir

ディレクトリ操作関連の関数。

### エクスポート関数

- `getcwdW()` - カレントディレクトリを取得
- `chdirW($dir)` - カレントディレクトリを変更
- `mkdirW($dir)` - ディレクトリを作成
- `rmdirW($dir)` - ディレクトリを削除
- `rmtreeW($dir [, $stop])` - ディレクトリツリーを再帰的に削除
- `mkpathW($dir)` - ディレクトリパスを再帰的に作成
- `cptreeW($from, $to [, $over])` - ディレクトリツリーをコピー
- `mvtreeW($from, $to [, $over])` - ディレクトリツリーを移動
- `findW($code, @dirs)` - ディレクトリツリーを検索してコードを実行（File::Find互換）
- `finddepthW($code, @dirs)` - 深さ優先でディレクトリツリーを検索
- `file_type($attr, $file)` - ファイルタイプを判定（属性: f=file, d=directory, e=exists, s=system, r=readonly, h=hidden, a=archive, n=normal, t=temporary, c=compressed, o=offline, i=not content indexed, E=encrypted）
- `file_size($file)` - ファイルサイズを取得
- `dir_size($dir)` - ディレクトリサイズを取得
- `file_list($dir)` - ディレクトリ内のファイル一覧を取得
- `dir_list($dir)` - ディレクトリ内のサブディレクトリ一覧を取得

### オブジェクト指向メソッド

- `Win32::Unicode::Dir->new()` - Dirオブジェクトを作成
- `$obj->open($dir)` - ディレクトリを開く
- `$obj->close()` - ディレクトリを閉じる
- `$obj->fetch()` - ディレクトリエントリを取得（readdir互換）
- `$obj->error()` - エラーメッセージを取得

## Win32::Unicode::Error

エラー処理関連の関数。

### エクスポート関数

- `errorW()` - 最後のWindows APIエラーメッセージを取得
- `error()` - errorW()のエイリアス

## Win32::Unicode::File

ファイル操作関連の関数。

### エクスポート関数

- `unlinkW(@files)` - ファイルを削除
- `copyW($from, $to [, $over])` - ファイルをコピー
- `moveW($from, $to [, $over])` - ファイルを移動・リネーム
- `renameW($from, $to [, $over])` - moveW()のエイリアス
- `touchW(@files)` - ファイルを作成またはタイムスタンプを更新
- `statW($file)` - ファイル情報を取得（CORE::stat互換）
- `utimeW($atime, $mtime, @files)` - ファイルのタイムスタンプを変更
- `file_type($attr, $file)` - ファイルタイプを判定
- `file_size($file)` - ファイルサイズを取得

### オプションエクスポート関数

- `filename_normalize($filename)` - ファイル名を正規化（Win32で使用できない文字を全角文字に変換）
- `slurp($file [, %opts])` - ファイル全体を読み込む

### オブジェクト指向メソッド

- `Win32::Unicode::File->new([$mode, $file])` - Fileオブジェクトを作成
- `$obj->open($mode, $file)` - ファイルを開く（モード: <, >, >>, +<, +>, +>>）
- `$obj->close()` - ファイルを閉じる
- `$obj->read($buf, $len [, $offset])` - ファイルから読み込む
- `$obj->readline()` - ファイルから1行読み込む
- `$obj->print(@args)` - ファイルへ書き込む
- `$obj->printf($format, @args)` - フォーマットされた文字列をファイルへ書き込む
- `$obj->write($buf [, $len, $offset])` - ファイルへ書き込む
- `$obj->seek($pos, $whence)` - ファイルポインタを移動
- `$obj->tell()` - 現在のファイルポインタ位置を取得
- `$obj->eof()` - ファイル終端かどうかを判定
- `$obj->binmode([$layer])` - バイナリモードまたはエンコーディングを設定
- `$obj->flock($operation)` - ファイルロック
- `$obj->slurp([%opts])` - ファイル全体を読み込む
- `$obj->flush()` - バッファをフラッシュ
- `$obj->autoflush([$bool])` - 自動フラッシュを設定

## Win32::Unicode::Process

プロセス実行関連の関数。

### エクスポート関数

- `systemW(@args)` - コマンドを実行して終了を待つ（CORE::system互換）
- `execW(@args)` - コマンドを実行して制御を移す（CORE::exec互換）

## Win32::Unicode::Util

ユーティリティ関数。

### エクスポート関数

- `utf16_to_utf8($str)` - UTF-16文字列をUTF-8に変換
- `utf8_to_utf16($str)` - UTF-8文字列をUTF-16に変換
- `cygpathw($path)` - Cygwin環境でパスを変換
- `to64int($high, $low)` - 32bit整数2つから64bit整数を生成
- `is64int($num)` - 64bit整数かどうかを判定
- `catfile(@paths)` - パスを結合
- `splitdir($path)` - パスをディレクトリ要素に分割
- `rel2abs($path [, $base])` - 相対パスを絶対パスに変換
- `close_handle($handle)` - Windows APIハンドルを閉じる

## Win32::Unicode::Constant

Windows API定数定義。

### 定数カテゴリ

#### 一般定数
- `NULL`, `NULLP`, `MAX_PATH`, `BUFF`, `TRUE`, `FALSE`, `INFINITE`
- `CYGWIN` - Cygwin環境判定
- `_32INT`, `_S32INT` - 32bit整数境界値

#### コンソール関連
- `STD_INPUT_HANDLE`, `STD_OUTPUT_HANDLE`, `STD_ERROR_HANDLE`
- `MAX_BUFFER_SIZE`

#### ファイル属性
- `FILE_ATTRIBUTE_READONLY`, `FILE_ATTRIBUTE_HIDDEN`, `FILE_ATTRIBUTE_SYSTEM`
- `FILE_ATTRIBUTE_DIRECTORY`, `FILE_ATTRIBUTE_ARCHIVE`, `FILE_ATTRIBUTE_NORMAL`
- `FILE_ATTRIBUTE_TEMPORARY`, `FILE_ATTRIBUTE_COMPRESSED`, `FILE_ATTRIBUTE_OFFLINE`
- `FILE_ATTRIBUTE_ENCRYPTED`, `FILE_ATTRIBUTE_NOT_CONTENT_INDEXED`

#### ファイル操作定数
- `GENERIC_READ`, `GENERIC_WRITE`, `GENERIC_EXECUTE`
- `FILE_SHARE_READ`, `FILE_SHARE_WRITE`, `FILE_SHARE_DELETE`
- `CREATE_NEW`, `CREATE_ALWAYS`, `OPEN_EXISTING`, `OPEN_ALWAYS`, `TRUNCATE_EXISTING`
- `INVALID_VALUE`, `INVALID_HANDLE_VALUE`, `ERROR_NO_MORE_FILES`

#### エラーコード
- `NO_ERROR`, `ERROR_FILE_EXISTS`

## Win32::Unicode::Native

標準関数のUnicode対応オーバーライド。

`use Win32::Unicode::Native;` で標準関数をUnicode対応版にオーバーライドします。

### エクスポート関数

#### コンソール関数（W無しバージョン）
- `print`, `printf`, `warn`, `die`, `say`

#### ファイル操作関数（W無しバージョン）
- `unlink`, `rename`, `copy`, `move`, `touch`, `stat`, `utime`

#### ディレクトリ操作関数（W無しバージョン）
- `mkdir`, `rmdir`, `chdir`, `find`, `finddepth`, `mkpath`, `rmtree`, `mvtree`, `cptree`, `getcwd`

#### プロセス実行関数（W無しバージョン）
- `system`, `exec`

#### ファイル/ディレクトリハンドル操作
- `open($fh, $mode, $file)` - ファイルを開く
- `close($fh)` - ファイルを閉じる
- `opendir($dh, $dir)` - ディレクトリを開く
- `closedir($dh)` - ディレクトリを閉じる
- `readdir($dh)` - ディレクトリエントリを読み込む
- `flock($fh, $operation)` - ファイルロック

#### ユーティリティ関数
- `error()` - エラーメッセージを取得
- `file_size($file)` - ファイルサイズを取得
- `file_type($attr, $file)` - ファイルタイプを判定
- `dir_size($dir)` - ディレクトリサイズを取得
- `file_list($dir)` - ファイル一覧を取得
- `dir_list($dir)` - ディレクトリ一覧を取得
- `filename_normalize($filename)` - ファイル名を正規化
- `slurp($file)` - ファイル全体を読み込む
- `__FILE__` - 現在のスクリプトファイル名を返す

### 特記事項

- `STDOUT`, `STDERR` が自動的にUTF-8エンコーディングに設定される
- `@ARGV` が自動的にUTF-8にデコードされる
- 標準関数のUnicode対応版を提供するため、既存コードの移行が容易

## Win32::Unicode::XS

XSローダーモジュール。

内部使用のみ。直接使用することは想定されていません。
