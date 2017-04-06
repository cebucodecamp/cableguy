$:.push File.expand_path("../lib", __FILE__)
require 'palmade/cableguy/version'

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'minitest'

Rake::TestTask.new do |t|
  t.libs << %w(test lib)
  t.pattern = 'test/**/*_test.rb'
end

task :default => :test

FURY_USERNAME = 'cebucodecamp'

desc 'Build gem and push to gem repo to staging (repo.fury.io/cebucodecamp)'
task :build_and_stage => [ :build ] do
  gem_path = File.expand_path('../pkg/cableguy-%s.gem' % Palmade::Cableguy::VERSION, __FILE__)
  cmd = 'bundle exec fury push --as=%s %s' % [ FURY_USERNAME, gem_path ]

  puts cmd; system(cmd); puts "\n"
end
