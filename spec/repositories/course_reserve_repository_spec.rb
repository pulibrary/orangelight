# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourseReserveRepository do
  describe '.all' do
    before do
      stub_all_query
    end
    subject(:repository) { described_class.all }

    it 'returns a relation of all available course reserves' do
      expect(repository.to_a.length).to eq 2
    end
    it 'has bulk accessors for instructors' do
      expect(repository.instructors).to eq [
        'Schupbach, Gertrud M.',
        'Bassler, Bonnie L.'
      ]
    end
    it 'has bulk accessors for departments' do
      expect(repository.departments).to eq [
        'MOL: Molecular Biology'
      ]
    end
    it 'has bulk accessors for courses' do
      expect(repository.course_names).to eq [
        'MOL 342: Genetics',
        'MOL 101: From DNA to Human Complexity'
      ]
    end
    it 'has bulk accessors for reserve IDs' do
      expect(repository.reserve_list_ids).to eq [
        1958,
        2087
      ]
    end

    context 'when the course reserve server is unavailable' do
      let(:relation) { described_class.all }

      before do
        allow(Faraday).to receive(:get).and_raise(Faraday::ClientError, 'error')
        allow(Rails.logger).to receive(:error)
      end

      it 'logs an error message' do
        expect(relation).to be_a CourseReserveRepository::Relation
        expect(relation.courses).to eq []
        expect(Rails.logger).to have_received(:error).with('Failed to retrieve the course information from the server: error')
      end
    end

    context 'when 500 responses are received for course reserve data' do
      before do
        stub_request(:get, "#{ENV['bibdata_base']}/courses")
          .to_return(
            status: 500,
            body: ["status", 500].to_json
          )
      end

      it 'returns a relation of all available course reserves' do
        expect(repository.to_a).to be_empty
      end
    end
  end

  def stub_all_query
    stub_request(:get, "#{ENV['bibdata_base']}/courses")
      .to_return(status: 200,
                 body: all_results.to_json)
  end

  def all_results
    [
      {
        reserve_list_id: 1958,
        department_name: 'Molecular Biology',
        department_code: 'MOL',
        course_name: 'Genetics',
        course_number: 'MOL 342',
        section_id: 171,
        instructor_first_name: 'Gertrud M.',
        instructor_last_name: 'Schupbach'
      },
      {
        reserve_list_id: 2087,
        department_name: 'Molecular Biology',
        department_code: 'MOL',
        course_name: 'From DNA to Human Complexity',
        course_number: 'MOL 101',
        section_id: 0,
        instructor_first_name: 'Bonnie L.',
        instructor_last_name: 'Bassler'
      }
    ]
  end
end
