#!/usr/bin/env ruby

# Script for loading users and tokens from OpenNebula to user configfile for dyndnsd

require 'opennebula'
require 'yaml'

include OpenNebula

# OpenNebula credentials
CREDENTIALS = '<<user>>:<<password>>'.freeze
# XML_RPC endpoint where OpenNebula is listening
ENDPOINT    = 'http://<<opennebula-server>>:2633/RPC2'.freeze
# File where userconfig for dynds should be placed
OUTFILE = '/etc/dyndnsd/users.conf'.freeze
# Users to exclude from export (array of IDs)
EXCLUDE = [].freeze
# Domains to to be managed by users
DOMAINS = [].freeze

client = Client.new(CREDENTIALS, ENDPOINT)

userpool = UserPool.new(client)

rc = userpool.info
if OpenNebula.is_error?(rc)
  puts rc.message
  exit 1
end

users['users'] = {}

userpool.each do |user|
  next if EXCLUDE.include?(user['ID'].to_i)
  name = user['NAME']
  pass = user['TEMPLATE/TOKEN_PASSWORD']
  domains = DOMAINS.map { |domain| "*.#{name}.#{domain}" }
  users['users'][name] = {
    'password' => pass,
    'hosts' => domains
  }
end

File.open(OUTFILE, 'w') { |file| file.write(users.to_yaml) }
