# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module Karafka
      module Interchangers
        class Base64Interchanger
          def encode(params_batch)
            Base64.encode64(Marshal.dump(super))
          end

          def decode(params_string)
            Marshal.load(Base64.decode64(super))
          end
        end
      end
    end
  end
end
