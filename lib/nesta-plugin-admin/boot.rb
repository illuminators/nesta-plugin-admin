# encoding: utf-8

require_relative './utils/ruby_compatibility.rb'

['models', 'helpers', 'routes'].each do |dirname|
  Dir.glob("#{__dir__}/#{dirname}/*.rb").each do |file|
    require file
  end
end
