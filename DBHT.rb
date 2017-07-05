# coding: utf-8
require 'csv'
require 'twitter'
require 'oauth'
require 'oauth/consumer'
require 'rbconfig'
require './keys.rb'

SourcePath = File.expand_path('../', __FILE__)
CSVFile = "#{SourcePath}/tweets.csv"
TokenFile = "#{SourcePath}/token"

def os
  @os ||= (
    host_os = RbConfig::CONFIG['host_os']
    case host_os
    when  /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      :windows
    when /darwin|mac os/
      :macosx
    when /linux/
      :linux
    when /solaris|bsd/
      :unix
    else
      raise Error::WebDriverError, "unknown os: #{host_os.inspect}"       
    end
  )
end

def oauth_first
  @consumer = OAuth::Consumer.new(CONSUMER_KEY ,CONSUMER_SECRET,{
    :site=>"https://api.twitter.com"
  })

  @request_token = @consumer.get_request_token

  puts "Please access this URL: #{@request_token.authorize_url}"
  puts "and get the Pin code."

  print "Enter your Pin code :"
  pin  = gets.chomp

  @access_token = @request_token.get_access_token(:oauth_verifier => pin)

  open(TokenFile, "a" ){|f| f.write("#{@access_token.token}\n")}
  open(TokenFile, "a" ){|f| f.write("#{@access_token.secret}\n")}
end

def print_usage
  puts <<EOS
DBHT - Delete Black History of Twitter
--------------------------------------------------
Usage: 1. Deploy Your tweets.csv in this directory
     2. Run This Program

© 2014-2015 sh4869 <nobuk4869@gmail.com>		 
EOS
end

def main
  if ARGV[0] == "-h" 
    print_usage
    exit
  end

  unless File::exist?(TokenFile)
    oauth_first
  end
  #Read File 
  @access_token = ""
  @access_secret = ""

  filelines  = open(TokenFile).readlines
  @access_token = filelines[0].gsub("\n","")
  @access_secret = filelines[1].gsub("\n","")

  @rest_client = Twitter::REST::Client.new do |config|
    config.consumer_key        = CONSUMER_KEY
    config.consumer_secret     = CONSUMER_SECRET
    config.access_token        = @access_token
    config.access_token_secret = @access_secret
  end

  unless File::exist?(CSVFile)
    puts "Error : Tweets.csv Not Found"
    print_usage
    exit 1
  end 

  cnt = 0
  if Encoding.locale_charmap == "CP65001" && os == :windows
    puts "このプログラムはCP65001に対応していません。chcp 932と実行してからもう一度実行してください。"
  end

  puts "どんな文字の含まれたツイートを消したいか入力してください。"
  delete_word = gets.chomp
  if os == :windows
    if Encoding.locale_charmap == "CP932"
      delete_word = delete_word.encode("UTF-8","Shift_JIS")  
    end
  end

  tweet_ids = []
  CSV.foreach("tweets.csv") do |tweet|
    if tweet[5].lines.grep(/(.+)?#{delete_word}(.+)?/) != []
        tweet_ids.push(tweet[0])
      cnt += 1
      puts "#{cnt} | text:#{tweet[5]} URL: #{"https://twitter.com/statues/" + tweet[0]}"
    end
  end

  if cnt == 0
    puts "#{delete_word}という文字列を含むツイートは見つかりませんでした。"
  else 
    puts "#{delete_word}という文字列を含むツイートを#{cnt}個発見しました。"
    puts "本当に削除しますか? (Y/n)"
    answer = gets.chomp
    if answer == "y" || answer == "Y"
      tweet_ids.each { |id|
        begin 
          @rest_client.destroy_status(id)  
        rescue => ex
          puts "Error -  ツイートが削除できませんでした。 id:#{id} Error:#{ex.message}"
          cnt -= 1
        end
      }

      str =  "#{delete_word}という文字列を含む#{cnt}個のツイートを削除しました."
      puts str
      puts "この結果をツイートしますか? (Y/n)"
      answer = gets.chomp
      if answer == "y" || answer == "Y"
        @rest_client.update(str + " | by https://github.com/sh4869/DBHT")
      end	
    end
  end
end 

main
