#coding: utf-8
require 'twitter'
require 'csv'
require 'oauth'
require 'oauth/consumer'
require './keys.rb'

SourcePath = File.expand_path('../', __FILE__)
TokenFile = "#{SourcePath}/token"

def oauth_first
  @consumer = OAuth::Consumer.new(CONSUMER_KEY ,CONSUMER_SECRET,{
      :site=>"https://api.twitter.com"
	    })

  @request_token = @consumer.get_request_token

  puts "Please access this URL: #{@request_token.authorize_url}"
  puts "and get the Pin code."

  print "Enter your Pin code:"
  pin  = gets.chomp

  @access_token = @request_token.get_access_token(:oauth_verifier => pin)

  open(TokenFile, "a" ){|f| f.write("#{@access_token.token}\n")}
  open(TokenFile, "a" ){|f| f.write("#{@access_token.secret}\n")}
end

unless File::exist?(TokenFile)
    oauth_first
end

open(TokenFile){ |file|
    ACCESS_TOKEN = file.readlines.values_at(0)[0].gsub("\n","")
}
open(TokenFile){ |file|
    ACCESS_SECRET = file.readlines.values_at(1)[0].gsub("\n","")
}  

@rest_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = CONSUMER_KEY
  config.consumer_secret     = CONSUMER_SECRET
  config.access_token        = ACCESS_TOKEN
  config.access_token_secret = ACCESS_SECRET
end

cnt = 0

puts "どんな文字の含まれたツイートを消したいか入力してください。"
delete = gets.chomp


CSV.foreach("tweets.csv") do |tweets|
  if tweets.grep(/(.+)?#{delete}(.+)?/) != []
	puts tweets
	at = tweets.first
	begin
	  @rest_client.destroy_status(at)
	rescue Twitter::Error::NotFound
	  puts "すでにそのツイートは消されている可能性があります。"
	  next
	ensure
	  cnt += 1
	end
  end
end

str =  "#{delete}という文字列を含む#{cnt}個のツイートを削除しました。"
puts str
puts "この結果をツイートしますか?　する:y しない:n"
ans = gets.chomp

while ans != "y" && ans !="n"
  puts "yかnで入力してください。"
  ans = gets.chomp
end

if ans == "y" 
  @rest_client.update(str)
  puts "ツイートしました。お疲れ様でした。"
elsif ans == "n"
  puts "お疲れ様でした"
end
