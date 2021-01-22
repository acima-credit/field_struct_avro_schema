# frozen_string_literal: true

namespace 'examples'

record :employee, doc: '| version 115d6e02' do
  required :first_name, :string, doc: '| type string'
  required :last_name, :string, doc: '| type string'
  optional :title, :string, doc: '| type string'
end
