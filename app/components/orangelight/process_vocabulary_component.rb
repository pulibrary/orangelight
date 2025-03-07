# frozen_string_literal: true

class Orangelight::ProcessVocabularyComponent < Blacklight::MetadataFieldComponent
  SEPARATOR = '—'
  QUERYSEP = '—'

  def subjectify(args)
    # args is a FieldPresenter
    subjects = args[:document][args[:field]]
    all_subjects = subjects.map { |subject| subject.split(QUERYSEP) }
    sub_array = subjects.map { |subject| accumulate_subsubjects(subject.split(QUERYSEP)) }
    subject_list = build_subject_list(args, all_subjects, sub_array)
    build_subject_ul(subject_list)
  end

  def build_subject_ul(subject_list)
    content_tag :ul do
      subject_list.each { |subject| concat(content_tag(:li, subject, dir: subject.dir)) }
    end
  end

  def build_subject_list(args, all_subjects, sub_array)
    args_document_field = args[:document][args[:field]]
    args_document_field.each_with_index do |_subject, index|
      sub_array_index = sub_array[index]
      lnk = build_search_subject_links(all_subjects[index], sub_array_index)
      lnk += build_browse_subject_link(args, index, sub_array_index.last)
      args_document_field[index] = lnk.html_safe
    end
  end

  def build_search_subject_links(subjects, sub_array)
    lnk = ''
    lnk_accum = ''

    subjects.each_with_index do |subsubject, j|
      sub_array_j = sub_array[j]
      lnk = lnk_accum + link_to(subsubject,
                                "/?f[subject_facet][]=#{CGI.escape StringFunctions.trim_punctuation(sub_array_j)}",
                                class: 'search-subject',
                                'data-original-title' => "Search: #{sub_array_j}")
      lnk_accum = lnk + content_tag(:span, SEPARATOR, class: 'subject-level')
    end
    lnk
  end

  def build_browse_subject_link(args, index, full_sub)
    return '  ' if fast_subjects_value?(args, index)

    '  ' + link_to("[Browse]",
                   "/browse/subjects?q=#{CGI.escape full_sub}",
                   class: 'browse-subject',
                   'data-original-title' => "Browse: #{full_sub}",
                   'aria-label' => "Browse: #{full_sub}",
                   dir: full_sub.dir.to_s)
  end

  def accumulate_subsubjects(spl_sub)
    spl_sub.reduce([]) do |accumulator, subsubject|
      # accumulator.last ? "#{accumulator.last}#{QUERYSEP}#{subsubject}" : subsubject
      accumulator.append([accumulator.last, subsubject].compact.join(QUERYSEP))
    end
  end
end
