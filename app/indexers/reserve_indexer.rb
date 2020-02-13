# frozen_string_literal: true

class ReserveIndexer
  class << self
    def index!(courses)
      new(courses).index!
    end

    def connection
      @connection ||= RSolr.connect url: connection_url
    end

    def connection_url
      ENV['RESERVES_SOLR_URL'] || Blacklight.default_index.connection.uri.to_s.chomp('/')
    end
  end

  attr_reader :courses
  def initialize(courses)
    @courses = courses
  end

  def index!
    documents = courses.map { |x| to_solr(x) }.reject { |x| Array(x[:bib_ids_s]).empty? }
    connection.add(documents, params: { softCommit: true })
  end

  private

    def to_solr(course)
      course.bib_ids = bib_ids.for_reserve(course.reserve_list_id)
      {
        id: "reserve-#{course.reserve_list_id}",
        type_s: 'ReserveListing',
        instructor_s: course.instructor,
        bib_ids_s: course.bib_ids,
        course_s: course.course_with_id,
        department_s: course.department_with_identifier
      }
    end

    def bib_ids
      @bib_ids ||= BibIdsRepository.for(courses.reserve_list_ids)
    end

    def connection
      self.class.connection
    end
end
