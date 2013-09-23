require "bundler/gem_tasks"

desc "Run pry in Nesta::Plugin::Admin context"
task :console do
  require './lib/nesta-plugin-admin/init.rb'
  require 'pry'
  require 'pry-debugger'

  Pry.start Nesta::Plugin::Admin
end

task :c => :console
