# frozen_string_literal: true
# This class represents an IETF Language Tag
#
# tag is the 2 or 3-letter language code (e.g. ar for Arabic)
# subtags is an array of additional information, in a specific order:
#  - script subtag (e.g. Latn for Latin script)
#  - region subtag (e.g. JO for Jordan)
#  - variant subtags, then extentions subtags, then private use subtags
LanguageTag = Struct.new(:tag, :subtags) do
  def to_s
    ([tag] + subtags).join('-')
  end

  # Returns a LanguageTag if the document has a language,
  # and nil if it does not
  def self.from_value(value, document)
    language_code = document[:language_iana_s]&.first
    return unless language_code
    if latin?(value)
      new(language_code, ['Latn'])
    else
      new(language_code, [])
    end
  end

  def self.latin?(value)
    value.codepoints.all? do |codepoint|
      # codepoint represents a Latin letter, diacritic, or punctuation
      codepoint < 880 ||
        # codepoint is a specialized charater used in Library of Congress
        # Romanization tables
        [4050, 8205, 9676, 65_056, 65_057].include?(codepoint)
    end
  end
end
