#!/usr/bin/env ruby
require 'rubygems'
require 'highline/import'
require 'net/imap'
require 'mail'

def getpass(prompt="Password:")
     ask(prompt) {|q| q.echo = false}
end

def idle_until_email(imap)
  email_num = nil 
  imap.idle do |response|
      if response.kind_of?(Net::IMAP::UntaggedResponse) and response.name == "EXISTS"
        email_num = response.data 
        imap.idle_done()
      end
  end

  raw_email = imap.fetch(email_num, 'RFC822').first
  return Mail.new(raw_email.attr['RFC822'])
end

def authenticate(imap)
  while true
    password = getpass()
    begin
      imap.login("grant.warman@gmail.com", password)
      return true 
    rescue
      puts "Invalid password"
      next
    end
  end
end

def main 
  imap = Net::IMAP.new("imap.gmail.com", ssl: true, port: 993)
  authenticate(imap)
  imap.select("INBOX")
  
  while true do
    email = idle_until_email(imap)
    puts "From: #{email.from.first}"
    puts email.text_part.decoded
  end
  
  imap.logout
end

if __FILE__ == $0
  main 
end
