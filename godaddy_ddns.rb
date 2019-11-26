#!/usr/bin/env ruby
# This script uses the GoDaddy API to update DNS A records 
# automatically if you dynamic IP changes
# 
# Author: A Pennington 12/2016

require 'open-uri'
require 'net/http'
require 'net/https'
require 'yaml'

def get_config()
    return YAML.load_file("#{get_file_path()}/godaddy_ddns.yaml") 
end

def get_file_path()
    return File.dirname(File.realpath(__FILE__));
end

def get_remote_ip(url)
    return open(url).read
end

def read_ipaddr_file(filename)
    file = open(filename, 'r')
    old_remote_ip = file.read.chomp
    file.close

    return old_remote_ip
end

def write_ipaddr_file(filename, remote_ip)
    file = open(filename, 'w')
    file.write(remote_ip)
    file.close
end

def update_godaddy(config, remote_ip, domain, record_type, record_name)
    uri = URI.parse("https://api.godaddy.com/v1/domains/#{domain}/records/#{record_type}/#{record_name}")
    req = Net::HTTP::Put.new(uri.path)

    # set constants
    req['Authorization'] = "sso-key #{config['api-key']}:#{config['secret']}"

    json =  <<-eos
    [
        {
            "data": "#{remote_ip}"
        }
    ]
    eos

    req.body = json
    req.content_type = 'application/json'

    https = Net::HTTP.new(uri.hostname, uri.port)
    https.use_ssl = true

    res = https.request(req)

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
        return true # success
    else
        STDERR.puts "HTTP Error: #{res.code} #{res.message}: #{res.body}"
    end

    return false
end

## Main

ipaddr_filename = "#{get_file_path()}/remote_ip.addr";
old_remote_ip = nil
error = false

config = get_config()

abort "ip-checker-url is empty, aborting..." unless config['ip-checker-url']

remote_ip = get_remote_ip(config['ip-checker-url'])

if (File.file?(ipaddr_filename))
    old_remote_ip = read_ipaddr_file(ipaddr_filename)
end

# if the ip address has changed then update!
if (old_remote_ip != remote_ip)
    for record_name in config['dns-arecords']
        success = update_godaddy(config, remote_ip, config['domain'], 'A', record_name)

        break unless success
    end

    write_ipaddr_file(ipaddr_filename, remote_ip) unless error
end

exit error ? 1 : 0

