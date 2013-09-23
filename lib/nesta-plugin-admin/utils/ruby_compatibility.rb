# encoding: utf-8

if RUBY_VERSION.to_i < 2
  class Object
    def __dir__
      # This works fine in ruby >= 1.9.0
      File.dirname(caller[0][/(.*?):\d+:in \u0060([^']*)'/, 1])
      # but this works only for ruby >= 2.0.0 :(
      #File.dirname(caller_locations[0].absolute_path)
    end
  end
end

