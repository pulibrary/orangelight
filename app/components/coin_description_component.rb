# frozen_string_literal: true

# An override of the metadata component with some customizations
# to make it suitable for displaying the coin description section
# of the show page
class CoinDescriptionComponent < Blacklight::DocumentMetadataComponent
  def initialize(fields: [], show: false, doc_presenter: nil)
    super(fields: fields, show: show)
    @doc_presenter = doc_presenter
  end

  def before_render
    @fields = @doc_presenter.field_presenters.select { |field| field.field_config&.coin_description } if @fields.empty? && @doc_presenter
    super
  end
end
