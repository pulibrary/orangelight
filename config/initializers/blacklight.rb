# frozen_string_literal: true

ActiveSupport::Reloader.to_prepare do
  Blacklight::Rendering::Pipeline.operations = [Blacklight::Rendering::HelperMethod,
                                                Orangelight::BrowseLinkProcessor,
                                                Orangelight::LinkToFacetProcessor,
                                                Orangelight::LinkToSearchValueProcessor,
                                                Orangelight::MarkAsSafeProcessor,
                                                Orangelight::ReferenceNoteUrlProcessor,
                                                Orangelight::SeriesLinkProcessor,
                                                Blacklight::Rendering::Microdata,
                                                Orangelight::JoinProcessor]
end
