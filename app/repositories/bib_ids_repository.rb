# frozen_string_literal: true

class BibIdsRepository
  class << self
    def for(reserve_ids)
      Relation.new(
        JSON.parse(
          Faraday.get("#{ENV['bibdata_base']}/bib_ids") do |req|
            req.params = { reserve_id: reserve_ids }
          end.body
        )
      )
    end
  end

  class Relation
    attr_reader :relations
    def initialize(relations)
      self.relations = relations
    end

    def to_a
      @to_a ||= relations
    end

    def for_reserve(reserve_id)
      to_a.select do |reserve|
        reserve.reserve_list_id == reserve_id
      end.flat_map(&:bib_id).uniq
    end

    private

      def relations=(relations)
        @relations = relations.map { |x| BibIDRelation.new(*x.values) }
      end
  end

  BibIDRelation = Struct.new(:reserve_list_id, :bib_id)
end
