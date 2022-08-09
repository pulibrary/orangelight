# frozen_string_literal: true
require 'json'

f = File.read("#{File.dirname(__FILE__)}/../../public/context.json")
RELATORS ||= JSON.parse(f)['@context'].select { |_k, v| (v['@id'] || '').start_with? 'mrel:' }.keys
