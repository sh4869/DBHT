require 'oauth'
require 'oauth/consumer'
require './src/keys.rb'

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
