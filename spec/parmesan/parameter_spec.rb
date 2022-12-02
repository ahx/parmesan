# frozen_string_literal: true

require 'yaml'
require 'rack'

RSpec.describe Parmesan::Parameter do
  YAML.safe_load(File.read('spec/parameter-test-suite.yaml')).each do |topic|
    describe topic['title'] do
      topic['tests'].each do |test|
        definition = test.fetch('parameter')
        example_request = test.fetch('request')
        next unless test['focus']

        it "parses #{definition['name']} in #{definition['in']} '#{example_request.fetch('url')}'" do
          url = example_request.fetch('url')
          request = Rack::Request.new(Rack::MockRequest.env_for(url))

          subject = described_class.new(definition)
          value = subject.value(request)
          expect(value).to eq(test['expected_value'])
          expect(subject.name).to eq definition['name']
          expect(subject.location).to eq definition['in']
          expect(subject.schema).to eq definition['schema']
        end
      end
    end
  end

  describe 'when parameter definition has a $refs' do
    it 'raises an error'
  end

  describe '#style' do
    it 'returns the style if defined' do
      parameter = described_class.new('style' => 'form', 'in' => 'query')
      expect(parameter.style).to eq 'form'
    end

    describe 'when style is not defined' do
      it 'returns "form" for query parameters' do
        parameter = described_class.new('in' => 'query')
        expect(parameter.style).to eq 'form'
      end

      it 'returns "simple" for path parameters' do
        parameter = described_class.new('in' => 'query')
        expect(parameter.style).to eq 'form'
      end

      it 'returns "simple" for header parameters' do
        parameter = described_class.new('in' => 'query')
        expect(parameter.style).to eq 'form'
      end

      it 'returns "form" for cookie parameters' do
        parameter = described_class.new('in' => 'query')
        expect(parameter.style).to eq 'form'
      end
    end
  end

  describe '#explode?' do
    it 'returns true if explode is true' do
      parameter = described_class.new('explode' => true, 'in' => 'query')
      expect(parameter.explode?).to be true
    end

    it 'returns false if explode is false' do
      parameter = described_class.new('explode' => false, 'in' => 'query')
      expect(parameter.explode?).to be false
    end

    describe 'when explode is not specified' do
      it 'returns true if style is "form"' do
        parameter = described_class.new('style' => 'form', 'in' => 'query')
        expect(parameter.explode?).to be true
      end

      it 'returns false if style is not "form"' do
        parameter = described_class.new('style' => 'spaceDelimited', 'in' => 'query')
        expect(parameter.explode?).to be false
      end
    end
  end
end
