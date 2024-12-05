# frozen_string_literal: true

class Orangelight::SortNormalize
  def normalize(string)
    normalize_greek_characters remove_diacritics(string)
      .gsub(/—/, ' ')
      .gsub(/[\p{P}\p{S}]/, '')
      .downcase(:fold)
  end

    private

      def remove_diacritics(string)
        diacritic_combining_characters = [*0x1DC0..0x1DFF, *0x0300..0x036F, *0xFE20..0xFE2F].pack('U*')
        decomposed_version = string.unicode_normalize(:nfd)
        decomposed_version.tr(diacritic_combining_characters, '')
      end

      def normalize_greek_characters(string)
        string.tr('ς', 'σ')
      end
end
