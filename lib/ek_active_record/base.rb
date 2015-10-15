module EkActiveRecord
  class Base

    @@config = {
        db_folder: 'db'
    }

    @@valid_config_keys = @@config.keys

    def self.config
      @@config
    end

    # Configure through hash
    def self.configure(opts = {})
      opts.each {|k,v| @@config[k.to_sym] = v if @@valid_config_keys.include? k.to_sym}
    end

    def self.attr_accessor(*vars)
      @attributes ||= []
      @attributes.concat vars
      super(*vars)
    end

    def self.attributes
      @attributes
    end

    def attributes
      self.class.attributes
    end

    def self.table_name
      @table_name ||= self.name.to_s.downcase
    end

    def self.table_name=(name)
      @table_name = name
    end


    def self.primary_key
      @primary_key ||= :id
    end

    def self.primary_key=(name)
      @primary_key = name
    end

  end
end