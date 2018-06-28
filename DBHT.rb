require 'csv'
require 'twitter'
require 'oauth'
require 'oauth/consumer'
require 'rbconfig'
require './keys.rb'

SOURCEPATH = File.expand_path(__dir__)
CSVPATH = "#{SOURCEPATH}/tweets.csv".freeze
TOKENFILE = "#{SOURCEPATH}/token".freeze

def os
  os ||= begin
    host_os = RbConfig::CONFIG['host_os']
    case host_os
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      :windows
    when /darwin|mac os/
      :macosx
    when /linux/
      :linux
    when /solaris|bsd/
      :unix
    else
      raise "unknown os: #{host_os.inspect}"
    end
  end
  os
end

def save_oauth_token
  consumer = OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET,
                                 site: 'https://api.twitter.com')
  request_token = consumer.get_request_token
  puts "次のURLにアクセスしてアプリケーションを認可し、ピンを取得してください: #{request_token.authorize_url}"
  print 'Enter your Pin code :'
  pin = gets.chomp
  access_token = request_token.get_access_token(oauth_verifier: pin)

  File.open(TOKENFILE, 'a') do |f|
    f.write("#{access_token.token}\n")
    f.write("#{access_token.secret}\n")
  end
end

def print_usage
  puts <<USAGE
  DBHT - Delete Black History of Twitter
  --------------------------------------------------
  Usage:
    1. Download your tweets.csv and copy it in this directory
    2. Run This Program

  © 2014-2015 sh4869 <nobuk4869@gmail.com>
USAGE
  exit
end

def search_tweets(word)
  tweet_ids = []
  CSV.foreach(CSVPATH) do |tweet|
    if tweet[5].lines.grep(/(.+)?#{word}(.+)?/) != []
      tweet_ids.push(tweet[0])
      puts "text:#{tweet[5]} URL: #{'https://twitter.com/statuses/' + tweet[0]}"
    end
  end
  tweet_ids
end

def client
  filelines = File.open(TOKENFILE).readlines
  access_token = filelines[0].delete("\n")
  access_secret = filelines[1].delete("\n")

  rest_client = Twitter::REST::Client.new do |config|
    config.consumer_key        = CONSUMER_KEY
    config.consumer_secret     = CONSUMER_SECRET
    config.access_token        = access_token
    config.access_token_secret = access_secret
  end
  rest_client
end

def delete_tweets(ids)
  rest_client = client
  ids.each do |id|
    begin
      rest_client.destroy_status(id)
    rescue StandardError => ex
      puts "Error -  ツイートが削除できませんでした。 id:#{id} Error:#{ex.message}"
      ids.delete(id)
    end
  end
  ids.length
end

def encoding_check
  raise 'このプログラムはCP65001に対応していません。chcp 932と実行してからもう一度実行してください。' if Encoding.locale_charmap == 'CP65001' && os == :windows
end

def convert
  os == :windows && Encoding.locale_charmap == 'CP932'
end

def post_result(str)
  rest_client = client
  rest_client.update(str + ' | by https://github.com/sh4869/DBHT')
end

def main
  print_usage if ARGV[0] == '-h' || !File.exist?(CSVPATH)
  save_oauth_token unless File.exist?(TOKENFILE)

  puts 'どんな文字の含まれたツイートを消したいか入力してください。'
  delete_word = convert ? gets.chomp.encode('UTF-8', 'Shift_JIS') : gets.chomp
  tweet_ids = search_tweets(delete_word)
  if tweet_ids.empty?
    puts "#{delete_word}という文字列を含むツイートは見つかりませんでした。"
    exit
  end

  puts "#{delete_word}という文字列を含むツイートを#{tweet_ids.length}個発見しました。本当に削除しますか? (y/n)"
  exit if gets.chomp != 'y'

  result = delete_tweets(tweet_ids)
  str = "#{delete_word}という文字列を含む#{result}個のツイートを削除しました."
  puts str + 'この結果をツイートしますか? (y/n)'
  post_result(str) if gets.chomp == 'y'
end

main
