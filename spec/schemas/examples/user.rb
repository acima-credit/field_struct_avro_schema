namespace 'examples'

record :user, :doc=>"| version 53d47729" do
  required :username, :string, doc: "login | type string"
  optional :password, :string, doc: "| type string"
  required :age, :int, doc: "| type integer"
  required :owed, :float, doc: "amount owed to the company | type currency"
  required :source, :string, doc: "| type string"
  required :level, :int, doc: "| type integer"
  optional :at, :string, doc: "| type time"
  required :active, :boolean, default: false, doc: "| type boolean"
end
