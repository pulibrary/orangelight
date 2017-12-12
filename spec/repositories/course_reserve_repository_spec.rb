require 'rails_helper'

RSpec.describe CourseReserveRepository do
  describe '.all' do
    before do
      stub_all_query
    end
    subject { described_class.all }

    it 'returns a relation of all available course reserves' do
      expect(subject.to_a.length).to eq 2
    end
    it 'has bulk accessors for instructors' do
      expect(subject.instructors).to eq [
        'Schupbach, Gertrud M.',
        'Bassler, Bonnie L.'
      ]
    end
    it 'has bulk accessors for departments' do
      expect(subject.departments).to eq [
        'MOL: Molecular Biology'
      ]
    end
    it 'has bulk accessors for courses' do
      expect(subject.course_names).to eq [
        'MOL 342: Genetics',
        'MOL 101: From DNA to Human Complexity'
      ]
    end
    it 'has bulk accessors for reserve IDs' do
      expect(subject.reserve_list_ids).to eq [
        1958,
        2087
      ]
    end
  end

  def stub_all_query
    stub_request(:get, 'https://bibdata.princeton.edu/courses')
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
