$:.push File.expand_path("../lib", __FILE__)
require 'palmade/cableguy/version'

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'gemfury/tasks'

Rake::TestTask.new do |t|
  t.libs << %w(test lib)
  t.pattern = 'test/**/*_test.rb'
end

task :default => :test

desc "Perform gem build and push to Gemfury as 'nlevel'"
task :fury_release do
  Rake::Task['fury:release'].invoke(nil, 'cebucodecamp')
end
