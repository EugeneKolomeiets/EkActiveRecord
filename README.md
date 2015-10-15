# EkActiveRecord

Basic ActiveRecord Gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ek_active_record'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ek_active_record

## Usage

Ex:

    class Dog < EkActiveRecord::Core

      attr_accessor :id, :title, :age, :dog_attr

      validates :title, presence: true
      validates :age, min: 2, max:50

      self.table_name = 'dogs'
      self.primary_key = :title

      protected
    =begin
      def before_validate?
        true
      end

      def after_validate
      end

      def before_save?
        true
      end

      def after_save
      end
    =end

    end

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ek_active_record.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

