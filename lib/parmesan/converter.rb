module Parmesan
  class Converter
    def self.call(value, schema)
      new(value, schema).call
    end

    def initialize(value, schema)
      @value, @schema = value, schema
    end

    attr_reader :value, :schema

    def call
      return convert_object(value) if object?

      convert_value(schema, value)
    end

    def convert(value)
      Converter.call(value, schema)
    end

    def convert_value(schema, value)
      case schema && schema['type']
      when 'integer'
        Integer(value, 10)
      when 'number'
        Float(value)
      when 'boolean'
        value == 'true'
      else
        value
      end
    end

    def convert_object(value)
      value.each_with_object({}) do |(k, v), hsh|
        hsh[k] = convert_value(schema.fetch('properties').fetch(k), v)
      end
    end

    def type
      schema && schema['type']
    end

    def array?
      type == 'array'
    end

    def object?
      type == 'object'
    end
  end
end
