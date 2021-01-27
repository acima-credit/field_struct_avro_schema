# frozen_string_literal: true

module FieldStruct
  module AvroSchema
    module ValueConverters
      module Registry
        module_function

        def all
          @all ||= {}
        end

        def register(*klasses)
          klasses.each do |klass|
            klass.handles.each { |type| all[type.to_s] = klass }
          end
        end

        def find(type)
          all[type.to_s]
        end
      end
    end
  end
end
