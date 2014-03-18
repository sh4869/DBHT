#coding: utf-8
require 'twitter'
require 'csv'

rest_client = Twitter::REST::Client.new do |config|
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
	  rest_client.destroy_status(at)
	rescue Twitter::Error::NotFound
	  puts "エラーが発生した模様です。すでにそのツイートは消されている可能性があります。"
	  next
	ensure
	  cnt += 1
	end
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
  rest_client.update(str)
  puts "ツイートしました。お疲れ様でした。"
elsif ans == "n"
  puts "お疲れ様でした"
end
