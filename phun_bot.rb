#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'highline/import'
require 'mail'
require 'net/imap'

def getpass(prompt="Password:")
     ask(prompt) {|q| q.echo = false}
end

def idle_until_email(imap)
  puts "Idling...\n"
  email_num = nil 
  imap.idle do |response|
      if response.kind_of?(Net::IMAP::UntaggedResponse) and response.name == "EXISTS"
        puts "Email Received\n"
        email_num = response.data 
        imap.idle_done()
      end
  end

  puts "Exiting Idle...\n"
  raw_email = imap.fetch(email_num, 'RFC822').first
  return Mail.new(raw_email.attr['RFC822'])
end

def authenticate(imap)
  username = ask("Username:")
  while true
    password = getpass()
    begin
      imap.login(username, password)
      puts "[Success] Connected."
      return true 
    rescue
      puts "[Failure] Invalid password."
      next
    end
  end
end

def main 
  imap = Net::IMAP.new("imap.gmail.com", ssl: true, port: 993)
  authenticate(imap)
  mailbox_name = ask("Mailbox (i.e. INBOX or PHUN): ")
  imap.select(mailbox_name)
  
  while true do
    email = idle_until_email(imap)
    puts "From: #{email.from.first}"
    puts email.text_part
    #puts email.text_part.decoded
  end
  
  imap.logout
end

if __FILE__ == $0
  main 
end
