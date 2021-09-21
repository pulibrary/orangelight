# frozen_string_literal: true

##
# The creation and management of metadata are not neutral activities.
class ChangeTheSubject
  def self.terms_mapping
    {
      "Illegal Aliens": {
        replacement: "Undocumented Immigrants",
        rationale: "The term immigrant or undocumented/unauthorized immigrants are the terms LoC proposed as replacements for illegal aliens and other uses of the world alien in LCSH."
      }
    }
  end

  ##
  # Given a term, check whether there is a suggested replacement
  # @param [String] term
  # @return [Hash]
  def self.check(term)
    terms_mapping[term.to_sym]
  end
end
