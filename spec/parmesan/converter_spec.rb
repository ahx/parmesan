# frozen_string_literal: true

RSpec.describe Parmesan::Converter do
  it 'keeps unknown values' do
    expect(described_class.call('123', {})).to eq('123')
  end

  it 'keeps string values' do
    expect(described_class.call('123', 'type' => 'string')).to eq('123')
  end

  it 'converts a string to an integer' do
    expect(described_class.call('123', 'type' => 'integer')).to eq(123)
  end

  it 'converts a string to a float' do
    expect(described_class.call('12.3', 'type' => 'number')).to eq(12.3)
  end

  it 'converts a string to true' do
    expect(described_class.call('true', 'type' => 'boolean')).to eq(true)
  end

  it 'converts a string to false' do
    expect(described_class.call('false', 'type' => 'boolean')).to eq(false)
  end

  it 'ignores format' do
    expect(described_class.call('2020-09-15', 'type' => 'string', 'format' => 'date')).to eq('2020-09-15')
  end
end
