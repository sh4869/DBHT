DBHT
======

DBHT - Delete Black History of Twitter

tweets.csvを使ってTwitterの黒歴史を自由に削除します。

## 使い方

1. まず、Twitterの公式ウェブにPCからアクセスします。
2. その後、画面の右端の歯車のアイコンをクリックし、設定を選びます。
3. ユーザー情報の欄の一番したから「全ツイート履歴をダウンロード」を見つけ、ボタンをおします。
4. メールが来たら、そこに記載されているリンクに飛び、[tweets.zip]をダウンロードします。
5. それを適当なフォルダに解凍し、その中に入っている[tweets.csv]をコピーしてどこかに置きます。
6. このレポジトリをcloneします。

```zsh   
$git clone https://github.com/sh4869/Delete_BH_of_Twitter.git
```

7. そのフォルダにtweets.csvをいれます。
8. 次のコマンドをうてば完成です。 

```zsh
$bundle install
$bundle exec ruby delete_twitter_his.rb
```
最初にoauth認証をしてください。


##LICENSE

The MIT license

-----
(c) @2014 sh4869
