# frozen_string_literal: true

namespace 'examples'

record :team, doc: '| version 6ce37c6d' do
  required :name, :string, doc: '| type string'
  required :leader, :employee, namespace: 'examples', doc: '| type examples.employee'
  required :members, :array, items: 'examples.developer', doc: 'Team members | type array:examples.developer'
end
