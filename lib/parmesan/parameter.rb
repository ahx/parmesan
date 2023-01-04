# frozen_string_literal: true

require 'set'
require_relative 'converter'

module Parmesan
  ##
  # Represents a parameter in an OpenAPI operation.
  class Parameter
    def initialize(definition)
      check_supported!(definition)
      @definition = definition
    end

    attr_reader :definition

    def name
      definition['name']
    end

    ##
    # @return [String] The location of the parameter in the request, "path", "query", "header" or "cookie".
    def location
      definition['in']
    end

    ##
    # @param request [Rack::Request]
    # @return The value of the parameter from the request. This will first collect the value and then convert it to the type defined in the schema.
    def value(request)
      value = collect(request)
      self.convert(value)
    end

    def schema
      definition['schema']
    end

    def type
      schema && schema['type']
    end

    def style
      return definition['style'] if definition['style']

      DEFAULT_STYLE.fetch(location)
    end

    def explode?
      return definition['explode'] if definition.key?('explode')
      return true if style == 'form'

      false
    end

    ##
    # @param request [Rack::Request]
    # @return The value of the parameter from the request.
    #         This will be an array if the parameter schema type is an array type or an object if the parameter schema type is object,
    #         but it will not try to convert nested values.
    #         If the parameter schema type is not an array or object, the value will be a string.
    #         If the parameter is not present in the request, nil will be returned.
    def collect(request)
      return collect_array(request) if type == 'array'
      return collect_object(request) if type == 'object'

      Rack::Utils.parse_query(request.query_string)[name]
    end

    ##
    # @param value The value to convert.
    # @return The converted value. This method will convert the string/array/object value of the parameter to the type defined in the schema.
    def convert(value)
      Converter.call(value, schema)
    end

    DEFAULT_STYLE = {
      'query' => 'form',
      'path' => 'simple',
      'header' => 'simple',
      'cookie' => 'form',
    }.freeze
    private_constant :DEFAULT_STYLE

    private

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

    VALID_LOCATIONS = Set.new(%w[query header path cookie]).freeze
    private_constant :VALID_LOCATIONS

    def check_supported!(definition)
      if definition.values.any? { |v| v.is_a?(Hash) && v.key?('$ref') }
        raise NotSupportedError,
              "Parameter schema with $ref is not supported: #{definition.inspect}"
      end
      unless VALID_LOCATIONS.include?(definition['in'])
        raise ArgumentError,
              "Parameter definition must have an 'in' property defined which should be one of #{VALID_LOCATIONS.join(', ')}"
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
