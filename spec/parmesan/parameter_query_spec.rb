# frozen_string_literal: true

require 'yaml'
require 'rack'

RSpec.describe Parmesan::Parameter do
  describe 'No schema defined' do
    it "parses id from '/pets?id=abc'" do
      url = '/pets?id=abc'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = { 'in' => 'query', 'name' => 'id' }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq('abc')
    end
  end

  describe 'No schema type defined' do
    it "parses id from '/pets?id=abc'" do
      url = '/pets?id=abc'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = { 'in' => 'query', 'name' => 'id', 'schema' => {} }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq('abc')
    end
  end

  describe 'Simple string parameter' do
    it "parses id from '/pets?id=abc'" do
      url = '/pets?id=abc'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = {
        'in' => 'query',
        'name' => 'id',
        'schema' => {
          'type' => 'string',
        },
      }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq('abc')
    end

    it "parses pet-id from '/pets?pet-id=abc'" do
      url = '/pets?pet-id=abc'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = {
        'in' => 'query',
        'name' => 'pet-id',
        'schema' => {
          'type' => 'string',
        },
      }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq('abc')
    end

    it "parses filter[name] from '/pets?filter[name]=abc'" do
      url = '/pets?filter[name]=abc'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = {
        'in' => 'query',
        'name' => 'filter[name]',
        'schema' => {
          'type' => 'string',
        },
      }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq('abc')
    end

    it "parses x[[]abc] from '/pets?x[[]abc]=abc'" do
      url = '/pets?x[[]abc]=abc'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = {
        'in' => 'query',
        'name' => 'x[[]abc]',
        'schema' => {
          'type' => 'string',
        },
      }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq('abc')
    end
  end

  describe 'Integer parameter' do
    it "parses id from '/pets?id=1'" do
      url = '/pets?id=1'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = {
        'in' => 'query',
        'name' => 'id',
        'schema' => {
          'type' => 'integer',
        },
      }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq(1)
    end

    it "parses id from '/pets?id=12'" do
      url = '/pets?id=12'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = {
        'in' => 'query',
        'name' => 'id',
        'schema' => {
          'type' => 'integer',
        },
      }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq(12)
    end
  end

  describe 'Number parameter' do
    it "parses id from '/pets?id=2.99792458e8'" do
      url = '/pets?id=2.99792458e8'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = {
        'in' => 'query',
        'name' => 'id',
        'schema' => {
          'type' => 'number',
        },
      }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq(299792458.0)
    end

    it "parses id from '/pets?id=1.3'" do
      url = '/pets?id=1.3'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = {
        'in' => 'query',
        'name' => 'id',
        'schema' => {
          'type' => 'number',
        },
      }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq(1.3)
    end
  end

  describe 'Array explode true' do
    it 'applies explode true if explode is undefined' do
      url = '/pets?name=a&name=b&name=c'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = {
        'in' => 'query',
        'name' => 'name',
        'schema' => {
          'type' => 'array',
          'items' => {
            'type' => 'string',
          },
        },
      }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq(%w[a b c])
    end

    it "parses name from '/pets?name=a&name=b&name=c'" do
      url = '/pets?name=a&name=b&name=c'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = {
        'in' => 'query',
        'name' => 'name',
        'explode' => true,
        'style' => 'form',
        'schema' => {
          'type' => 'array',
          'items' => {
            'type' => 'string',
          },
        },
      }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq(%w[a b c])
    end

    it "parses name from '/pets?names[]=a&names[]=b&names[]=c'" do
      url = '/pets?names[]=a&names[]=b&names[]=c'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = {
        'in' => 'query',
        'name' => 'names[]',
        'explode' => true,
        'style' => 'form',
        'schema' => {
          'type' => 'array',
          'items' => {
            'type' => 'string',
          },
        },
      }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq(%w[a b c])
    end
  end

  describe 'Array explode false' do
    it "parses name from '/pets?name=a,b,c'" do
      url = '/pets?name=a,b,c'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = {
        'in' => 'query',
        'name' => 'name',
        'explode' => false,
        'style' => 'form',
        'schema' => {
          'type' => 'array',
          'items' => {
            'type' => 'string',
          },
        },
      }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq(%w[a b c])
    end

    it "parses name from '/pets?name=a%20b%20c'" do
      url = '/pets?name=a%20b%20c'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = {
        'in' => 'query',
        'name' => 'name',
        'explode' => false,
        'style' => 'spaceDelimited',
        'schema' => {
          'type' => 'array',
          'items' => {
            'type' => 'string',
          },
        },
      }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq(%w[a b c])
    end

    it "parses name from '/pets?name=a%7Cb%7Cc'" do
      url = '/pets?name=a%7Cb%7Cc'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = {
        'in' => 'query',
        'name' => 'name',
        'explode' => false,
        'style' => 'pipeDelimited',
        'schema' => {
          'type' => 'array',
          'items' => {
            'type' => 'string',
          },
        },
      }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq(%w[a b c])
    end
  end

  describe 'Object explode true' do
    it "parses color from '/pets?color[R]=100&color[G]=200&color[B]=150'" do
      url = '/pets?color[R]=100&color[G]=200&color[B]=150'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = {
        'in' => 'query',
        'name' => 'color',
        'explode' => true,
        'style' => 'deepObject',
        'schema' => {
          'type' => 'object',
          'properties' => {
            'R' => {
              'type' => 'integer',
            },
            'G' => {
              'type' => 'integer',
            },
            'B' => {
              'type' => 'integer',
            },
          },
        },
      }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq({ 'R' => 100, 'G' => 200, 'B' => 150 })
    end
  end

  describe 'Object explode false' do
    it "parses name from '/pets?color=R,100,G,200,B,150'" do
      url = '/pets?color=R,100,G,200,B,150'
      request = Rack::Request.new(Rack::MockRequest.env_for(url))
      definition = {
        'in' => 'query',
        'name' => 'color',
        'explode' => false,
        'style' => 'form',
        'schema' => {
          'type' => 'object',
          'properties' => {
            'R' => {
              'type' => 'integer',
            },
            'G' => {
              'type' => 'integer',
            },
            'B' => {
              'type' => 'integer',
            },
          },
        },
      }
      subject = described_class.new(definition)
      value = subject.value(request)
      expect(value).to eq({ 'R' => 100, 'G' => 200, 'B' => 150 })
    end
  end
end
