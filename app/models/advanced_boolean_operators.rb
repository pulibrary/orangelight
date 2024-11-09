# frozen_string_literal: true
# This class is responsible for reading some boolean operators
# (AND, OR, or NOT) from some URL query params, and translating
# them into the operators that Solr's BoolQParser likes (must,
# must_not, or should)
class AdvancedBooleanOperators
  def initialize(parameters)
    @parameters = parameters
  end

  def for_boolqparser
    parameters.without(:boolean_operator1, :boolean_operator2).deep_merge(clauses)
  end

    private

      attr_reader :parameters

      def first_operator
        parameters['boolean_operator1']&.upcase
      end

      def second_operator
        parameters['boolean_operator2']&.upcase
      end

      def clauses
        if first_operator.present? || second_operator.present?
          { clause: { '0': { op: first_boolqparser_param }, '1': { op: middle_boolqparser_param }, '2': { op: last_boolqparser_param } } }
        else
          {}
        end
      end

      def first_boolqparser_param
        return 'must' if first_operator == 'AND'
        return 'must' if first_operator == 'NOT' && second_operator != 'OR'
        'should'
      end

      def middle_boolqparser_param
        return 'should' if second_operator == 'OR' && first_operator != 'NOT'
        mapping = {
          'OR' => 'should',
          'NOT' => 'must_not',
          'AND' => 'must'
        }
        mapping[first_operator] || 'should'
      end

      def last_boolqparser_param
        mapping = {
          'OR' => 'should',
          'NOT' => 'must_not',
          'AND' => 'must'
        }
        mapping[second_operator] || 'should'
      end
end
