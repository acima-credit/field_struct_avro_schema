# FieldStruct AvroSchema

`FieldStruct` provides a lightweight approach to having typed structs in three flavors: `Flexible`, `Strict` 
and `Mutable`.

This gem provides support for Avro schemas for FieldStruct classes.

## Usage

Say you have a user class like this:

```ruby
require 'field_struct'
require 'field_struct/avro_schema'

class Friend < FieldStruct.strict
  required :name, :string
  optional :age, :integer
  optional :balance_owed, :currency, default: 0.0
  optional :gamer_level, :integer, enum: [1,2,3], default: -> { 1 }  
  optional :zip_code, :string, format: /\A[0-9]{5}?\z/  
end

puts Friend.metadata.as_avro_schema.inspect
# {
#   :type => "record", 
#   :name => "friend", 
#   :namespace => "",
#   :doc => "| version 82f78509", 
#   :fields => [
#     { :name => :name, :type => "string", :doc => "| type string" }, 
#     { :name => :age, :type => ["null", "int"], :doc => "| type integer" }, 
#     { :name => :balance_owed, :type => ["float", "null"], :default => 0.0, :doc => "| type currency" },
#     { :name => :gamer_level, :type => ["null", "int"], :doc => "| type integer" }, 
#     { :name => :zip_code, :type => ["null", "string"], :doc => "| type string" }
#   ]
# }

puts Friend.metadata.to_avro_json true
# {
#   "type": "record",
#   "name": "friend",
#   "namespace": "",
#   "doc": "| version 82f78509",
#   "fields": [
#     {
#       "name": "name",
#       "type": "string",
#       "doc": "| type string"
#     },
#     {
#       "name": "age",
#       "type": [
#         "null",
#         "int"
#       ],
#       "doc": "| type integer"
#     },
#     {
#       "name": "balance_owed",
#       "type": [
#         "float",
#         "null"
#       ],
#       "default": 0.0,
#       "doc": "| type currency"
#     },
#     {
#       "name": "gamer_level",
#       "type": [
#         "null",
#         "int"
#       ],
#       "doc": "| type integer"
#     },
#     {
#       "name": "zip_code",
#       "type": [
#         "null",
#         "string"
#       ],
#       "doc": "| type string"
#     }
#   ]
# }

schema = Friend.metadata.to_avro_schema; schema.class.name
# => "Avro::Schema::RecordSchema" 
``` 

We can also generate a new FieldStruct metadata from the Avro definition we just generated. 
And with that we can generate a new FieldStruct class.

```ruby
meta = FieldStruct::Metadata.from_avro_schema Friend.metadata.as_avro_schema
# => [#<FieldStruct::Metadata name="Schemas::::Friend::V82f78509" version="82f78509" type=:flexible>]
FieldStruct.from_metadata meta.last
# => Schemas::Friend::V82f78509
```

And with that new class we can create new instances:

```ruby 
john = Schemas::Friend::V82f78509.new age: 18
# => #<Schemas::Friend::V82f78509 age=18 balance_owed=0.0>  
john.valid?
# => false
john.errors.messages
# => {:name=>["can't be blank"]}
john = Schemas::Friend::V82f78509.new name: 'John', age: 18
# => #<Schemas::Friend::V82f78509 name="John" age=18 balance_owed=0.0>
john.valid?
# => true 
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'field_struct_avro_schema'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install field_struct_avro_schema

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/acima-credit/field_struct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
