# frozen_string_literal: true

class CourseReserveRepository
  class << self
    def all
      Relation.new(courses)
    end

    private

      def courses_response
        Faraday.get("#{ENV['bibdata_base']}/courses")
      end

      def courses
        values = courses_response.body
        JSON.parse(values)
      rescue Faraday::ClientError => client_error
        Rails.logger.error("Failed to retrieve the course information from the server: #{client_error.message}")
        []
      end
  end

  class Relation
    attr_reader :courses
    attr_accessor :query_params
    delegate :map, to: :to_a
    def initialize(courses, query_params = {})
      self.courses = courses
      self.query_params = query_params
    end

    def solr_query
      QueryBuilder.new(query_params).to_s
    end

    class QueryBuilder
      attr_reader :instructor, :course, :department
      def initialize(query_params)
        self.instructor = query_params.fetch(:instructor, nil)
        self.course = query_params.fetch(:course_with_id, nil)
        self.department = query_params.fetch(:department_with_identifier, nil)
      end

      def instructor=(instructor)
        return if instructor.blank?
        @instructor = instructor
      end

      def course=(course)
        return if course.blank?
        @course = course
      end

      def department=(department)
        return if department.blank?
        @department = department
      end

      def to_s
        (['type_s:ReserveListing'] + %i[instructor course department].map do |x|
          to_query(x)
        end).compact.join(' AND ')
      end

      private

        def to_query(field)
          value = send(field)
          return unless value
          "#{field}_s:\"#{value}\""
        end
    end

    def query(query_params)
      self.class.new(
        select do |course|
          query_params.map do |key, value|
            value.blank? || course.send(key) == value
          end.uniq == [true]
        end.to_a,
        query_params.merge(self.query_params)
      )
    end

    def to_a
      @to_a ||= courses
    end

    def select(&block)
      self.class.new(to_a.select(&block))
    end

    def instructors
      @instructors ||= courses.map(&:instructor).uniq
    end

    def departments
      @departments ||= courses.map(&:department_with_identifier).uniq
    end

    def course_names
      @course_names ||= courses.map(&:course_with_id).uniq
    end

    def reserve_list_ids
      @reserve_list_ids ||= courses.map(&:reserve_list_id).uniq
    end

    private

      def courses=(courses)
        @courses = courses.map { |x| Course.new(*x.values) }
      end
  end

  Course = Struct.new(:reserve_list_id, :department_name, :department_code, :course_name,
                      :course_number, :section_id, :instructor_first_name,
                      :instructor_last_name) do
    attr_accessor :bib_ids
    def instructor
      "#{instructor_last_name}, #{instructor_first_name}"
    end

    def department_with_identifier
      "#{department_code}: #{department_name}"
    end

    def course_with_id
      "#{department_code} #{filtered_course_number}: #{course_name}"
    end

    def filtered_course_number
      course_number.split(' ').last
    end
  end
end
