# frozen_string_literal: true
# Takes Advanced Search clauses with written booleans and puts them in the correct structure for Solr
class BooleanPhrase
  attr_reader :solr_parameters

  def initialize(solr_parameters)
    @solr_parameters = solr_parameters
  end

  # left_anchor_search
  # duplication of logic with other booleans
  # SO LONG
  # Process-y, not OO
  # tests that don't run in CI
  # :reek:TooManyStatements
  def fancy_booleans
    return unless must_clauses
    # Find phrase with OR
    phrases_with_or = must_clauses&.select do |clause|
      # still need to deal with ALL CAPS QUERIES WITH OR IN THE MIDDLE
      clause[:edismax][:query].include?('OR')
    end
    # take phrase with OR out of "must" array
    phrases_with_or&.each do |phrase|
      boolean_phrase['must'].delete(phrase)
    end
    # split into individual phrases for each part of "should" and put in "should" array
    should_array = build_should_clause(phrases_with_or)
    # create "should" clause
    # What if there's already a should clause from another field?
    boolean_phrase['should'] = should_array if should_array.present?

    return unless must_clauses.empty?
    boolean_phrase.delete('must')
  end

  private

    def boolean_phrase
      solr_parameters['json']['query']['bool']
    end

    def must_clauses
      solr_parameters.dig('json', 'query', 'bool', 'must')
    end

    # Need a test that iterates through this more than once
    def build_should_clause(phrases_with_or)
      phrases_with_or&.reduce([]) do |clause_array, phrase|
        # {"must" => [{edismax: query: "potato OR spinach"}]}
        sub_phrases = phrase[:edismax][:query].split(' OR ')
        clause_array + arr_to_edismax_arr(sub_phrases)
      end
    end

    def arr_to_edismax_arr(terms)
      terms.map do |sub_phrase|
        edismax_query_clause(sub_phrase)
      end
    end

    def edismax_query_clause(term)
      { edismax: { query: term } }
    end
end
