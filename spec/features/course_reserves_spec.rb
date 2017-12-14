require 'rails_helper'

describe 'course reserves functionality' do
  before do
    stub_all_query
    stub_bib_ids
  end
  it 'displays appropriate course reserves' do
    visit '/course_reserves'
    click_link 'MOL 101: From DNA to Human Complexity'
    expect(page).to have_selector '.document', count: 1
  end

  def stub_all_query
    stub_request(:get, "#{ENV['bibdata_base']}/courses")
      .to_return(status: 200,
                 body: all_results.to_json)
  end

  def stub_bib_ids
    stub_1
    stub_2
    stub_3
    stub_4
  end

  def stub_1
    stub_request(:get, "#{ENV['bibdata_base']}/bib_ids?reserve_id[]=1958&reserve_id[]=2088")
      .to_return(status: 200,
                 body: (reserve_1 + reserve_3).to_json)
  end

  def stub_2
    stub_request(:get, "#{ENV['bibdata_base']}/bib_ids?reserve_id[]=1958&reserve_id[]=2087&reserve_id[]=2088")
      .to_return(status: 200,
                 body: (reserve_1 + reserve_2 + reserve_3).to_json)
  end

  def stub_3
    stub_request(:get, "#{ENV['bibdata_base']}/bib_ids?reserve_id[]=2087")
      .to_return(status: 200,
                 body: reserve_2.to_json)
  end

  def stub_4
    stub_request(:get, "#{ENV['bibdata_base']}/bib_ids?reserve_id[]=2088")
      .to_return(status: 200,
                 body: reserve_3.to_json)
  end

  def reserve_1
    [
      {
        reserve_list_id: 1958,
        bib_id: 4_705_304
      }
    ]
  end

  def reserve_2
    [
      {
        reserve_list_id: 2087,
        bib_id: 430_472
      }
    ]
  end

  def reserve_3
    [
      {
        reserve_list_id: 2088,
        bib_id: 345_682
      }
    ]
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
        instructor_first_name: 'Jane',
        instructor_last_name: 'Test'
      },
      {
        reserve_list_id: 2088,
        department_name: 'Molecular Biology',
        department_code: 'MOL',
        course_name: 'Genetics',
        course_number: 'MOL 343',
        section_id: 171,
        instructor_first_name: 'Jane',
        instructor_last_name: 'Test'
      },
      {
        reserve_list_id: 2087,
        department_name: 'Molecular Biology',
        department_code: 'MOL',
        course_name: 'From DNA to Human Complexity',
        course_number: 'MOL 101',
        section_id: 0,
        instructor_first_name: 'Joe',
        instructor_last_name: 'Test'
      }
    ]
  end
end
