require 'yaml'
require 'erb'

module Palmade::Cableguy
  class CablingValues
    attr_reader :cabler
    attr_reader :values

    def self.load_cabling_values(cabler, path)
      self.new(cabler).load_values(path)
    end

    def self.new_empty(cabler)
      self.new(cabler).empty!
    end

    def initialize(cabler)
      @cabler = cabler
      @values = nil
    end

    def load_values(path)
      vf_contents = File.read(path)
      vf_contents = ERB.new(vf_contents).result(binding)

      parsed_vf = YAML.load(vf_contents)
      if parsed_vf.nil? || parsed_vf == false
        @values = new_values
      else
        @values = new_values(parsed_vf)
      end

      self
    end

    def empty!
      @values = new_values

      self
    end

    protected

    def new_values(vals = nil)
      if vals.nil?
        h = Hash.new
      else
        h = Hash.new.update(vals)
      end

      h
    end
  end
end
