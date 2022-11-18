module Parmesan
  module TypeConversion
    def self.convert(value, schema)
      case schema["type"]
      when "integer"
        value.to_i
      when "number"
        value.to_f
      when "boolean"
        value == "true"
      else
        value
      end
    end
  end
end
