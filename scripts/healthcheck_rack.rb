#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'

url = URI.parse('https://localhost:9292/')
req = Net::HTTP::Get.new(url.to_s)
res = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }

if res.code == '200'
  exit 0
else
  exit 1
end
