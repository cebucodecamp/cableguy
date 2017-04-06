$:.push File.expand_path('../lib', __FILE__)
require 'palmade/cableguy/version'

Gem::Specification.new do |s|
  s.name        = 'cableguy'
  s.version     = Palmade::Cableguy::VERSION

  s.authors     = [ 'Cebu Code Campers' ]
  s.email       = [ 'core@cebucodecamp.org' ]
  s.homepage    = 'https://github.com/cebucodecamp/cableguy'

  s.summary     = %q{Generate configurations based on a template and a cabling database}
  s.description = %q{Generate configurations based on a template and a cabling database}
  s.rubyforge_project = 'cableguy'

  s.add_dependency 'sqlite3'
  s.add_dependency 'sequel'
  s.add_dependency 'thor'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = [ 'lib' ]
end
