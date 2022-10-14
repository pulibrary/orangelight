# frozen_string_literal: true
Blacklight::Rendering::Pipeline.operations = [Blacklight::Rendering::HelperMethod,
                                              Orangelight::BrowseLinkProcessor,
                                              Orangelight::LinkToFacetProcessor,
                                              Orangelight::LinkToSearchValueProcessor,
                                              Orangelight::MarkAsSafeProcessor,
                                              Orangelight::ReferenceNoteUrlProcessor,
                                              Orangelight::SeriesLinkProcessor,
                                              Blacklight::Rendering::Microdata,
                                              Orangelight::JoinProcessor]
