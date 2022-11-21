# frozen_string_literal: true

require "yaml"
require "rack"


RSpec.describe Parmesan::Parameter do
  YAML.safe_load(File.read("spec/parameter-test-suite.yaml")).each do |topic|
    describe topic["title"] do
      topic["tests"].each do |test|
        definition = test.fetch("parameter")
        example_request = test.fetch("request")
        it "parses #{definition["name"]} in #{definition["in"]} '#{example_request.fetch("url")}'" do
          url = example_request.fetch("url")
          request = Rack::Request.new(Rack::MockRequest.env_for(url))

          subject = described_class.new(definition)
          value = subject.value(request)
          expect(value).to eq(test["expected_value"])
          expect(subject.name).to eq definition["name"]
          expect(subject.location).to eq definition["in"]
          expect(subject.schema).to eq definition["schema"]
        end
      end
    end
  end

  describe 'when parameter definition has a $refs' do
    it 'raises an error'

    it 'calls an external $ref resolver if specified'
  end
end
