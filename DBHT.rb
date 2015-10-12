#coding: utf-8
require 'csv'
require 'twitter'
require 'oauth'
require 'oauth/consumer'
require './keys.rb'

SourcePath = File.expand_path('../', __FILE__)
CSVFile = "#{SourcePath}/tweets.csv"
TokenFile = "#{SourcePath}/token"

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
  file = open(TokenFile)
  access_token = file.readlines[0]
  access_secret = file.readlines[1]
  file.close  

  @rest_client = Twitter::REST::Client.new do |config|
	config.consumer_key        = CONSUMER_KEY
	config.consumer_secret     = CONSUMER_SECRET
	config.access_token        = access_token
	config.access_token_secret = access_secret
  end

  unless File::exist?(CSVFile)
	puts "Error : Tweets.csv Not Found"
	print_usage
	exit 1
  end 

  cnt = 0
  puts "どんな文字の含まれたツイートを消したいか入力してください。"
  delete_word = gets.chomp

  CSV.foreach("tweets.csv") do |tweets|
	if tweets[5].lines.grep(/(.+)?#{delete_word}(.+)?/) != []
		at = tweets.first
	  begin
		print "id:#{at} "
		@rest_client.destroy_status(at)
	  rescue Twitter::Error::NotFound
		puts "すでにそのツイートは消されている可能性があります。"
		next
	  else
		cnt += 1
		puts "text:#{tweets[5]} time:#{tweets[3]}"
	  end
	end
  end

  str =  "#{delete_word}という文字列を含む#{cnt}個のツイートを削除しました."
  puts str
  puts "この結果をツイートしますか?　する:y しない:n"
  answer = gets.chomp
  if answer == "y" || answer == "Y"
	@rest_client.update(str + " | by https://github.com/sh4869/DBHT")
  end	
end 

main
