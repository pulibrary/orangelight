module Requests
  class Libcal
    class << self
      def url(library_code)
        "https://libcal.princeton.edu/seats?lid=#{code_to_libcal[library_code]}"
      end

      private

        def code_to_libcal
          {
            "firestone" => "1919", "engineering" => "7832", "lewis" => "3508", "stokes" => "2353", "eastasian" => "10604",
            "mendel" => "10653", "architecture" => "10655", "marquand" => "10656"
          }
        end
    end
  end
end
