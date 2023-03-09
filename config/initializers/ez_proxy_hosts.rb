# frozen_string_literal: true
require 'set'

host_set = Set.new

File.readlines("#{File.dirname(__FILE__)}/../hosts.dat").each do |line|
  host_set << line.chomp
end

EZ_PROXY_HOST_LIST ||= host_set
