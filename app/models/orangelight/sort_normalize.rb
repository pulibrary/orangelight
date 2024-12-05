# frozen_string_literal: true

# Stringex (upstream):
# It normalizes and romanizers everything

# Stringex/forked:
# Alphabetic Presentation Forms (Latin ligatures) FB00–FB06
# Halfwidth and Fullwidth Forms (fullwidth Latin letters) FF00–FF5E
#     ##### OTHER SCRIPTS #####
# Combining Diacritical Marks, 0300-036F
# Greek, 0384-03CE
# Cyrillic, 0400-045F
# Armenian, 0531-0587

# It normalizes the latin characters and Greek Cyrillic Armenian.
# It does not romanize Greek, Cyrillic, Armenian.

# For all other languages it does not normalize (for example chinese)

# ============================

# Unidecode:
# It normalizes everything and romanizes everything.

# ============================

# Orangelight::SortNormalize:
# For lating characters it normalizes some of them. We haven't covered all of them.
#   - Maybe we will use Unidecode for latin if needed
# It normalizes Greek and not romanizing.
# It normalizes Cyrillic but has a bug.
# It normalizes Armenian but we're not very confident.

# For all other languages we keep them as they are.

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
