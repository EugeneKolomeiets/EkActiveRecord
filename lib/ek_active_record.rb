require "json"
require "ek_active_record/version"
require "ek_active_record/base"

module EkActiveRecord
  class Core < EkActiveRecord::Base

    def self.count
      table_hash.count
    end

    def self.all
      make_object_array(table_hash)
    end

    def self.find_by_pk(pk)
      hash = table_hash
      hash.each do |row|
        return make_object(row) if row[primary_key] == pk
      end
      return nil
    end

    def self.where(args)
      raise 'Params keys should be symbols' if args.keys.map(&:class).uniq != [Symbol]

      result = []
      table_hash.each do |row|
        found = true
        args.each do |key, arg|
          if row[key] != arg
            found = false
          end
        end
        if found
          result.push(row)
        end
      end
      make_object_array(result)
    end

    def self.destroy_all
      File.open(table_path, 'w') do
      end
    end

    #########################

    def save
      if valid?
        if before_save?
          hash = merge_hash(self.class.table_hash, to_hash)
          write_to_db(hash)

          after_save
          return true
        end
      end
      false
    end

    def destroy
      pk = instance_variable_get("@#{self.class.primary_key}")
      if pk.nil? || pk.to_s.empty?
        raise 'Blank primary key'
      end

      hash = substract_hash(self.class.table_hash, to_hash)
      write_to_db(hash)
    end


    def self.validates(name, options = {})
      @rules ||= []
      if options.any?
        options.each do |key, value|
          raise 'Params should be symbols' if key.class != Symbol
          case key
            when :presence
              raise 'Only boolean values for :presence ' unless [true, false].include? value
            when :min, :max
              raise ':' + key.to_s + ' value must be Numeric' unless value.is_a? Numeric
            else
              raise 'Undefined symbol :' + key.to_s
          end
        end
      end
      @rules.push({name => options})
    end

    def self.get_rules
      @rules ||= []
    end

    def valid?
      if before_validate?
        rules = self.class.get_rules
        unless rules.nil?
          rules.each do |rule|
            rule.each do |key, option|
              return false if validate_rule?(instance_variable_get("@#{key}"), option) == false
            end
          end
        end
        after_validate
        return true
      end
      false
    end

    def validate_rule?(model_value, options = {})
      if options.any?
        options.each do |key, value|
          case key
            when :presence
              return false if (value == true && (model_value.nil? || (model_value.is_a?(String) && model_value.strip.empty?)))
            when :min
              return false if (![Fixnum, Float].include?(model_value.class) || model_value < value)
            when :max
              return false if (![Fixnum, Float].include?(model_value.class) || model_value > value)
            else
              raise 'Undefined symbol :' + key.to_s
          end
        end
      end
      true
    end

    #########################

    protected

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

    #########################

    private

    def self.table_path
      @@config[:db_folder] + File::SEPARATOR + table_name + '.json'
    end

    def self.table_hash
      file = File.read(table_path)
      file.empty? ? [] : JSON.parse(file, :symbolize_names => true)
    end

    def self.make_object(hash)
      raise 'make_object argument is not a Hash' unless hash.is_a? Hash

      obj = self.new
      hash.each do |key, value|
        obj.send("#{key}=", value)
      end
      obj
    end

    def self.make_object_array(hash_array)
      object_array = []
      if hash_array.any?
        hash_array.each do |el|
          object_array.push(make_object(el))
        end
      end
      object_array
    end

    def to_hash
      attributes.each_with_object({}) do |attr, hash|
        hash[attr] = instance_variable_get("@#{attr}")
      end
    end

    def merge_hash(db_hash, model_hash)
      found = false
      db_hash.map! do |row|
        if row[self.class.primary_key] == model_hash[self.class.primary_key]
          found = true
          row = model_hash
        else
          row
        end
      end
      if !found
        db_hash.push(model_hash)
      end

      db_hash
    end

    def substract_hash(db_hash, model_hash)
      db_hash.map do |row|
        if row[self.class.primary_key] != model_hash[self.class.primary_key]
          row
        end
      end.compact
    end

    def write_to_db(hash)
      File.open(self.class.table_path, 'w') do |f|
        f.write(hash.to_json)
      end
    end

  end
end
