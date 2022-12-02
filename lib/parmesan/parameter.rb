# frozen_string_literal: true

require 'set'

module Parmesan
  class Parameter
    def initialize(definition)
      @definition = definition
      return if location_valid?(definition['in'])

      raise ArgumentError,
            "Parameter definition must have an 'in' property defined which should be one of #{IN_VALUES.join(', ')}"
    end

    attr_reader :definition

    def name
      definition['name']
    end

    def location
      definition['in']
    end

    IN_VALUES = Set.new(%w[query header path cookie]).freeze
    private_constant :IN_VALUES
    def location_valid?(location)
      IN_VALUES.include?(location)
    end

    def schema
      definition['schema']
    end

    DEFAULT_STYLE = {
      'query' => 'form',
      'path' => 'simple',
      'header' => 'simple',
      'cookie' => 'form',
    }.freeze
    private_constant :DEFAULT_STYLE
    def style
      return definition['style'] if definition['style']

      DEFAULT_STYLE.fetch(location)
    end

    def explode?
      return definition['explode'] if definition.key?('explode')
      return true if style == 'form'

      false
    end

    def value(request)
      value = collect(request)
      convert_top_level(value)
    end

    def collect(request)
      return collect_array(request) if array?
      return collect_object(request) if object?

      Rack::Utils.parse_query(request.query_string)[name]
    end

    def collect_array(request)
      return request.params[name].split(array_delimiter) unless explode?

      query_parts = request.query_string.split('&')
      result = []
      query_parts.each do |part|
        param_hash = Rack::Utils.parse_query(part)
        result << param_hash[name] if param_hash.key?(name)
      end
      result
    end

    def collect_object(request)
      return request.params[name] if explode?

      Hash[*request.params[name]&.split(',')]
    end

    def type
      schema&.key?('type') && schema['type']
    end

    def array?
      type == 'array'
    end

    def object?
      type == 'object'
    end

    def convert_top_level(value)
      return convert_object(value) if object?

      convert(schema, value)
    end

    def convert(schema, value)
      type = schema&.key?('type') && schema['type']

      case type
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
        hsh[k] = convert(schema.fetch('properties').fetch(k), v)
      end
    end

    DELIMERS = {
      'pipeDelimited' => '|',
      'spaceDelimited' => ' ',
      'form' => ',',
      'simple' => ',',
    }.freeze

    def array_delimiter
      DELIMERS.fetch(definition['style'], ',')
    end
  end
end
