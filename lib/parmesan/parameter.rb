# frozen_string_literal: true

require_relative "type_conversion"

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
      convert(request.params[name])
    end

    private

    def convert(value)
      return value unless schema&.key?("type")
      TypeConversion.convert(value, schema)
    end
  end
end
