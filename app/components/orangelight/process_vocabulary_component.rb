# frozen_string_literal: true

class Orangelight::ProcessVocabularyComponent < Blacklight::MetadataFieldComponent
  def subjectify
    subjects = @field.values
    all_subjects = subjects.map { |subject| subject.split(QUERYSEP) }
    sub_array = subjects.map { |subject| accumulate_subsubjects(subject.split(QUERYSEP)) }
    subject_list = build_subject_list(all_subjects, sub_array)
    build_subject_ul(subject_list)
  end

private

  SEPARATOR = '—'
  QUERYSEP = '—'
  private_constant :SEPARATOR, :QUERYSEP

  def build_subject_ul(subject_list)
    content_tag :ul do
      subject_list.each { |subject| concat(content_tag(:li, subject, dir: subject.dir)) }
    end
  end

  def build_subject_list(all_subjects, sub_array)
    document_field = @field.values
    document_field.each_with_index do |_subject, index|
      sub_array_index = sub_array[index]

      lnk = build_search_subject_links(all_subjects[index], sub_array_index)
      lnk += build_browse_subject_link(index, sub_array_index.last).to_s
      # rubocop:disable Rails/OutputSafety
      document_field[index] = lnk.html_safe
      # rubocop:enable Rails/OutputSafety
    end
  end

  def build_search_subject_links(subjects, sub_array)
    facet_keys = {
      'lc_subject_display' => 'lc_subject_facet',
      'aat_s' => 'aat_genre_facet',
      'homoit_subject_display' => 'homoit_subject_facet',
      'homoit_genre_s' => 'homoit_genre_facet',
      'lcgft_s' => 'lcgft_genre_facet',
      'local_subject_display' => 'local_subject_facet',
      'fast_subject_display' => 'subject_facet_display',
      'rbgenr_s' => 'rbgenr_genre_facet',
      'siku_subject_display' => 'siku_subject_facet'
    }

    subjects.each_with_index.reduce('') do |acc, (subsubject, j)|
      sub_array_j = sub_array[j]
      facet_key = facet_keys[@field.key]
      acc + build_search_subject_link(subsubject, sub_array_j, facet_key) + content_tag(:span, SEPARATOR, class: 'subject-level')
    end
  end

  def build_search_subject_link(subsubject, sub_array_j, facet_key)
    link_to(subsubject,
            "/?f[#{facet_key}][]=#{CGI.escape StringFunctions.trim_punctuation(sub_array_j)}",
            class: 'search-subject',
            'data-original-title' => "Search: #{sub_array_j}")
  end

  # rubocop:disable Metrics/MethodLength
  def build_browse_subject_link(index, full_sub)
    return '  ' if fast_subjects_value?(index)
    # rubocop:disable Style/StringConcatenation
    case @field.key
    when 'lc_subject_display'
      '  ' + link_to("[Browse]",
                     "/browse/subjects?q=#{CGI.escape full_sub}&vocab=lc_subject_facet",
                     class: 'browse-subject',
                     'data-original-title' => "Browse: #{full_sub}",
                     'aria-label' => "Browse: #{full_sub}",
                     dir: full_sub.dir.to_s)
    when 'aat_s'
      '  ' + link_to("[Browse]",
                     "/browse/subjects?q=#{CGI.escape full_sub}&vocab=aat_genre_facet",
                     class: 'browse-subject',
                     'data-original-title' => "Browse: #{full_sub}",
                     'aria-label' => "Browse: #{full_sub}",
                     dir: full_sub.dir.to_s)
    when 'homoit_subject_display'
      '  ' + link_to("[Browse]",
                     "/browse/subjects?q=#{CGI.escape full_sub}&vocab=homoit_subject_facet",
                     class: 'browse-subject',
                     'data-original-title' => "Browse: #{full_sub}",
                     'aria-label' => "Browse: #{full_sub}",
                     dir: full_sub.dir.to_s)
    when 'homoit_genre_s'
      '  ' + link_to("[Browse]",
                     "/browse/subjects?q=#{CGI.escape full_sub}&vocab=homoit_genre_facet",
                     class: 'browse-subject',
                     'data-original-title' => "Browse: #{full_sub}",
                     'aria-label' => "Browse: #{full_sub}",
                     dir: full_sub.dir.to_s)
    when 'lcgft_s'
      '  ' + link_to("[Browse]",
                     "/browse/subjects?q=#{CGI.escape full_sub}&vocab=lcgft_genre_facet",
                     class: 'browse-subject',
                     'data-original-title' => "Browse: #{full_sub}",
                     'aria-label' => "Browse: #{full_sub}",
                     dir: full_sub.dir.to_s)
    when 'local_subject_display'
      '  ' + link_to("[Browse]",
                     "/browse/subjects?q=#{CGI.escape full_sub}&vocab=local_subject_facet",
                     class: 'browse-subject',
                     'data-original-title' => "Browse: #{full_sub}",
                     'aria-label' => "Browse: #{full_sub}",
                     dir: full_sub.dir.to_s)

    when 'rbgenr_s'
      '  ' + link_to("[Browse]",
                     "/browse/subjects?q=#{CGI.escape full_sub}&vocab=rbgenr_genre_facet",
                     class: 'browse-subject',
                     'data-original-title' => "Browse: #{full_sub}",
                     'aria-label' => "Browse: #{full_sub}",
                     dir: full_sub.dir.to_s)
    when 'siku_subject_display'
      '  ' + link_to("[Browse]",
                     "/browse/subjects?q=#{CGI.escape full_sub}&vocab=siku_subject_facet",
                     class: 'browse-subject',
                     'data-original-title' => "Browse: #{full_sub}",
                     'aria-label' => "Browse: #{full_sub}",
                     dir: full_sub.dir.to_s)
    end
    # rubocop:enable Style/StringConcatenation
  end
  # rubocop:enable Metrics/MethodLength

  def accumulate_subsubjects(spl_sub)
    spl_sub.reduce([]) do |accumulator, subsubject|
      # accumulator.last ? "#{accumulator.last}#{QUERYSEP}#{subsubject}" : subsubject
      accumulator.append([accumulator.last, subsubject].compact.join(QUERYSEP))
    end
  end

  def fast_subjects_value?(index)
    fast_subject_display_field = @field.document["fast_subject_display"]
    return false if fast_subject_display_field.nil?
    fast_subject_display_field.present? && fast_subject_display_field.include?(@field.values[index])
  end
end
