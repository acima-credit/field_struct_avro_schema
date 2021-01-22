# frozen_string_literal: true

namespace 'examples'

record :developer, doc: '| version 5251a97e' do
  required :first_name, :string, doc: '| type string'
  required :last_name, :string, doc: '| type string'
  optional :title, :string, doc: '| type string'
  required :language, :string, doc: '| type string'
end
