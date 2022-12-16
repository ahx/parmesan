# frozen_string_literal: true

require 'yaml'
require 'rack'

RSpec.describe Parmesan::Parameter do
  describe 'when parameter definition has a $refs' do
    it 'raises an error' do
      definition = { 'in' => 'query', 'name' => 'id', 'schema' => { '$ref' => '#/components/schemas/Pet' } }
      expect {described_class.new(definition)}.to raise_error(Parmesan::NotSupportedError)
    end
  end

  describe '#name' do
    it 'returns the name' do
      definition = { 'in' => 'query', 'name' => 'id' }
      subject = described_class.new(definition)
      expect(subject.name).to eq 'id'
    end
  end

  describe '#location' do
    it 'returns the "in" value' do
      definition = { 'in' => 'query', 'name' => 'id' }
      subject = described_class.new(definition)
      expect(subject.location).to eq 'query'
    end
  end

  describe '#schema' do
    it 'returns the schema' do
      definition = {
        'in' => 'query',
        'name' => 'id',
        'schema' => {
          'type' => 'string',
        },
      }
      subject = described_class.new(definition)
      expect(subject.schema).to eq({ 'type' => 'string' })
    end
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
        parameter = described_class.new('in' => 'path')
        expect(parameter.style).to eq 'simple'
      end

      it 'returns "simple" for header parameters' do
        parameter = described_class.new('in' => 'header')
        expect(parameter.style).to eq 'simple'
      end

      it 'returns "form" for cookie parameters' do
        parameter = described_class.new('in' => 'cookie')
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
        parameter =
          described_class.new('style' => 'spaceDelimited', 'in' => 'query')
        expect(parameter.explode?).to be false
      end
    end
  end
end
