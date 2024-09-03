# frozen_string_literal: true

class IndexTitleComponent < Blacklight::DocumentTitleComponent
  def title
    helpers.link_to_document presenter.document, title_text, counter: @counter, itemprop: 'name', style: title_style, dir: title_text.dir
  end

  def transliterated_title
    helpers.link_to_document presenter.document, transliterated_title_text, counter: @counter, itemprop: 'name', dir: transliterated_title_text.dir
  end

  private

    attr_reader :document

    def title_text
      document['title_vern_display'] || document['title_display'] || document['id']
    end

    def transliterated_title_text
      @transliterated_title_text ||= document['title_display'] if document['title_vern_display'].present?
    end

    def title_style
      return 'float: right;' if title_text.dir == 'rtl'
    end

    def title_has_been_transliterated?
      document['title_display'].present? && document['title_vern_display'].present?
    end
end
