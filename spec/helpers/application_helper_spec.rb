# frozen_string_literal: true
require 'rails_helper'

describe ApplicationHelper do
  describe '#subjectify' do
    let(:document) do
      {
        'lc_subject_display' => [
          'Menz family—Art patronage—Exhibitions',
          'Art patrons—Italy—Bolzano (Trentino-Alto Adige)—Exhibitions',
          'Art—Italy—Bolzano (Trentino-Alto Adige)—Exhibitions'
        ]
      }
    end
    let(:args) { { document: document, field: 'lc_subject_display' } }

    it 'returns a string containing an unordered list of subject links' do
      expect(subjectify(args)).to match(%r{<ul>.*</ul>})
    end

    it 'includes links for each sub-subject' do
      results = subjectify(args)
      expect(results).to include('href="/?f[subject_facet][]=')
      expect(results).to include('Menz family')
      expect(results).to include('Art patronage')
      expect(results).to include('Exhibitions')
    end

    it 'handles subjects with multiple sub-subjects' do
      results = subjectify(args)
      expect(results).to include('Menz family—Art patronage')
      expect(results).to include('Menz family—Art patronage—Exhibitions')
    end
  end
end
