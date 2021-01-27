# frozen_string_literal: true

module FieldStruct
  class Metadata
    def self.from_avro_schema(schemas, options = {})
      AvroSchema::MetadataBuilder.build schemas, options
    end
  end

  module AvroExtension
    def self.included(base)
      raise "#{base.name} does not respond to metadata" unless base.respond_to?(:metadata)
      raise "#{base.name} does not have a proper metadata" unless base.metadata.is_a? FieldStruct::Metadata

      base.send :extend, Base::ClassMethods
      base.send :include, Base::InstanceMethods
      base.metadata.send :extend, Meta::InstanceMethods
    end

    module Base
      module ClassMethods
        def inherited(child)
          super
          child.metadata.send :extend, Meta::InstanceMethods
        end

        def from_avro_hash(attrs)
          FieldStruct::AvroSchema::Converters.from_avro self, attrs
        end
      end

      module InstanceMethods
        def to_avro_hash
          FieldStruct::AvroSchema::Converters.to_avro self
        end
      end
    end

    module Meta
      module InstanceMethods
        def as_avro_template
          AvroSchema::AvroBuilder.build_template self
        end

        def as_avro
          AvroSchema::AvroBuilder.build self
        end

        def as_avro_schema
          JSON.parse(as_avro.to_s).deep_symbolize_keys
        end

        def to_avro_json(pretty = false)
          pretty ? JSON.pretty_generate(as_avro_schema) : as_avro_schema.to_json
        end
      end
    end
  end
end
