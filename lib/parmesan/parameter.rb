# frozen_string_literal: true

module Parmesan
  class Parameter
    def initialize(definition)
      @definition = definition
    end

    attr_reader :definition

    def name
      definition["name"]
    end

    def location
      definition["in"]
    end

    def schema
      definition["schema"]
    end

    def value(request)
      value = collect(request)
      convert(value)
    end

    def collect(request)
      request.params[name]
    end

    def convert(value)
      return value unless schema&.key?("type")
      case schema["type"]
      when "integer"
        Integer(value, 10)
      when "number"
        Float(value)
      when "boolean"
        value == "true"
      when "array"
        parse_array(value)
      when "object"
        parse_object(value)
      else
        value
      end
    end

    def parse_object(value)
      value
    end

    def convert_object(value)
    end

    def parse_array(value)
      value.split(array_delimiter)
    end

    DELIMERS = {
      'pipeDelimited' => '|',
      'spaceDelimited' => ' ',
      'form' => ','
    }.freeze

    def array_delimiter
      DELIMERS.fetch(definition["style"], ",")
    end
  end
end
