# frozen_string_literal: true
Blacklight::Rendering::Pipeline.operations = [Blacklight::Rendering::HelperMethod,
                                              Orangelight::LinkToFacet,
                                              Blacklight::Rendering::Microdata,
                                              Blacklight::Rendering::Join]
