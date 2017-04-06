require 'rubygems'
ROOT_PATH = CABLEGUY_ROOT_PATH = File.expand_path('../..', __FILE__)

begin
  require "rubygems"
  require "bundler"
rescue LoadError
  raise "Could not load the bundler gem. Install it with `gem install bundler`."
end

begin
  # Set up load paths for all bundled gems
  ENV["BUNDLE_GEMFILE"] = File.join(ROOT_PATH, 'Gemfile')
  Bundler.setup
rescue Bundler::GemNotFound
  raise RuntimeError, "Bundler couldn't find some gems." +
    "Did you run bundle install?"
end

module Boboot
  def self.root_path; ROOT_PATH; end

  def self.add_lib_to_load_path
    File.join(root_path, 'lib').tap { |p| $LOAD_PATH.unshift(p) unless $LOAD_PATH.include?(p) }
  end

  def self.require_relative_gem(gem_name, lib_path)
    require File.join(self.root_path, '..', gem_name, 'lib', lib_path)
  end

  def self.disable_rubygem_warns
    # Disables Rubygems warnings, as otherwise this is totally out of control
    if (defined?(Deprecate))
      Deprecate.skip = true
    elsif (defined?(Gem::Deprecate))
      Gem::Deprecate.skip = true
    end
  end

  def self.silence_warns
    original_verbosity = $VERBOSE
    $VERBOSE = nil
    result = yield
    $VERBOSE = original_verbosity
    result
  end
end

Boboot.disable_rubygem_warns
Boboot.add_lib_to_load_path

# explicitly disable warnings!
$VERBOSE = nil
