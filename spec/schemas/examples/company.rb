# frozen_string_literal: true

namespace 'examples'

record :company, doc: '| version bb40ff23' do
  required :legal_name, :string, doc: '| type string'
  optional :development_team, :team, namespace: 'examples', doc: '| type examples.team'
  optional :marketing_team, :team, namespace: 'examples', doc: '| type examples.team'
end
