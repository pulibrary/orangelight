# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AdvancedBooleanOperators do
  it 'returns must,must,must when original operators are AND,AND' do
    original = ActionController::Parameters.new({ boolean_operator1: 'AND', boolean_operator2: 'AND' })
    operators = described_class.new original
    expect(operators.for_boolqparser['clause']['0']['op']).to eq('must')
    expect(operators.for_boolqparser['clause']['1']['op']).to eq('must')
    expect(operators.for_boolqparser['clause']['2']['op']).to eq('must')
  end
  it 'returns must,should,should when original operators are AND,OR' do
    original = ActionController::Parameters.new({ boolean_operator1: 'AND', boolean_operator2: 'OR' })
    operators = described_class.new original
    expect(operators.for_boolqparser['clause']['0']['op']).to eq('must')
    expect(operators.for_boolqparser['clause']['1']['op']).to eq('should')
    expect(operators.for_boolqparser['clause']['2']['op']).to eq('should')
  end

  it 'returns must,must,must_not when original operators are AND,NOT' do
    original = ActionController::Parameters.new({ boolean_operator1: 'AND', boolean_operator2: 'NOT' })
    operators = described_class.new original
    expect(operators.for_boolqparser['clause']['0']['op']).to eq('must')
    expect(operators.for_boolqparser['clause']['1']['op']).to eq('must')
    expect(operators.for_boolqparser['clause']['2']['op']).to eq('must_not')
  end

  it 'returns should,should,must when original operators are OR,AND' do
    original = ActionController::Parameters.new({ boolean_operator1: 'OR', boolean_operator2: 'AND' })
    operators = described_class.new original
    expect(operators.for_boolqparser['clause']['0']['op']).to eq('should')
    expect(operators.for_boolqparser['clause']['1']['op']).to eq('should')
    expect(operators.for_boolqparser['clause']['2']['op']).to eq('must')
  end

  it 'returns should,should,should when original operators are OR,OR' do
    original = ActionController::Parameters.new({ boolean_operator1: 'OR', boolean_operator2: 'OR' })
    operators = described_class.new original
    expect(operators.for_boolqparser['clause']['0']['op']).to eq('should')
    expect(operators.for_boolqparser['clause']['1']['op']).to eq('should')
    expect(operators.for_boolqparser['clause']['2']['op']).to eq('should')
  end

  it 'returns should,should,must_not when original operators are OR,NOT' do
    original = ActionController::Parameters.new({ boolean_operator1: 'OR', boolean_operator2: 'NOT' })
    operators = described_class.new original
    expect(operators.for_boolqparser['clause']['0']['op']).to eq('should')
    expect(operators.for_boolqparser['clause']['1']['op']).to eq('should')
    expect(operators.for_boolqparser['clause']['2']['op']).to eq('must_not')
  end

  it 'returns must,must_not,must when original operators are NOT,AND' do
    original = ActionController::Parameters.new({ boolean_operator1: 'NOT', boolean_operator2: 'AND' })
    operators = described_class.new original
    expect(operators.for_boolqparser['clause']['0']['op']).to eq('must')
    expect(operators.for_boolqparser['clause']['1']['op']).to eq('must_not')
    expect(operators.for_boolqparser['clause']['2']['op']).to eq('must')
  end

  it 'returns should,must_not,should when original operators are NOT,OR' do
    original = ActionController::Parameters.new({ boolean_operator1: 'NOT', boolean_operator2: 'OR' })
    operators = described_class.new original
    expect(operators.for_boolqparser['clause']['0']['op']).to eq('should')
    expect(operators.for_boolqparser['clause']['1']['op']).to eq('must_not')
    expect(operators.for_boolqparser['clause']['2']['op']).to eq('should')
  end

  it 'returns must,must_not,must_not when original operators are NOT,NOT' do
    original = ActionController::Parameters.new({ boolean_operator1: 'NOT', boolean_operator2: 'NOT' })
    operators = described_class.new original
    expect(operators.for_boolqparser['clause']['0']['op']).to eq('must')
    expect(operators.for_boolqparser['clause']['1']['op']).to eq('must_not')
    expect(operators.for_boolqparser['clause']['2']['op']).to eq('must_not')
  end

  it 'leaves non-boolean_operator params intact' do
    original = ActionController::Parameters.new({ q: 'aardvark' })
    operators = described_class.new original
    expect(operators.for_boolqparser[:q]).to eq('aardvark')
  end

  it 'does not add any boolqparser clauses if the original did not have boolean_operator1 or boolean_operator2' do
    original = ActionController::Parameters.new({ q: 'aardvark' })
    operators = described_class.new original
    expect(operators.for_boolqparser['clause']).to be_blank
  end

  it 'retains existing non-operator clause data' do
    original = ActionController::Parameters.new({
                                                  clause: { '0': { query: 'artichoke' } },
                                                  boolean_operator1: 'NOT', boolean_operator2: 'OR'
                                                })
    operators = described_class.new original
    expect(operators.for_boolqparser['clause']['0']['op']).to eq('should')
    expect(operators.for_boolqparser['clause']['0']['query']).to eq('artichoke')
  end

  it 'removes boolean_operator1 or boolean_operator2' do
    original = ActionController::Parameters.new({ boolean_operator1: 'NOT', boolean_operator2: 'NOT' })
    operators = described_class.new original
    expect(operators.for_boolqparser['boolean_operator1']).to be_blank
    expect(operators.for_boolqparser['boolean_operator2']).to be_blank
  end
  it 'is case insensitive (you can use "AND" or "and")' do
    original = ActionController::Parameters.new({ boolean_operator1: 'and', boolean_operator2: 'aND' })
    operators = described_class.new original
    expect(operators.for_boolqparser['clause']['0']['op']).to eq('must')
    expect(operators.for_boolqparser['clause']['1']['op']).to eq('must')
    expect(operators.for_boolqparser['clause']['2']['op']).to eq('must')
  end
end
