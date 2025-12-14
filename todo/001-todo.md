
## File関連の便利関数の実装

以下の関数を作成して。
標準ライブラリのみで実装すること。

- ff($root_dir) -> List[str] root_dir のディレクトリのファイルを再帰的に取得する。絶対パスで取得して、配列で返す。
- ffa($root_dir~ -> List[str] ff と同じ
- ffr($root_dir) -> List[str] rootdir を基準とした相対パスの配列を返す
- fg($filepath) -> str ファイルの中身を返す
- fp($filepath, $content) ファイルに$contentを保存する
- md($dir) ディレクトリを作成する。　再帰的に作成できる。
- rm($file_or_dir) ファイルまたはディレクトリを削除する。ディレクトリの場合は再帰的に削除
- cp($src, $dest) ファイルをコピーする $destのディレクトリがない場合は作成
- mv($src, $dest) ファイルを移動する $destのディレクトリがない場合は作成

