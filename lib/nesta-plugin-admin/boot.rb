# encoding: utf-8

['models', 'helpers', 'routes'].each do |dirname|
  Dir.glob("#{__dir__}/#{dirname}/*.rb").each do |file|
    require file
  end
end
