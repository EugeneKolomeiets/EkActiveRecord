require 'spec_helper'

describe EkActiveRecord::Core do

  before :all do
    @new_db_folder = 'spec/db'
    @dog_title = 'test dog title'

    @model_db_path_dog = @new_db_folder + '/dogs.json'
    @model_db_path_cat = @new_db_folder + '/cat.json'

    FileUtils.cp(@new_db_folder + '/cat_default.json', @model_db_path_cat)
    FileUtils.cp(@new_db_folder + '/dogs_default.json', @model_db_path_dog)
  end

  after :all do
    FileUtils.rm(@model_db_path_dog)
    FileUtils.rm(@model_db_path_cat)
  end

  describe "configuration" do

    it "returns default config" do
      expect(EkActiveRecord::Core.config).to eq({db_folder: 'db'})
    end

    it "can set custom config" do
      EkActiveRecord::Core.configure({db_folder: @new_db_folder})
      expect(EkActiveRecord::Core.config).to eq({db_folder: @new_db_folder})
    end

    it "saved previous configuration" do
      expect(EkActiveRecord::Core.config).to eq({db_folder: @new_db_folder})
    end

  end

  describe "ActiveRecord" do

    describe "Class methods" do

      it "responds on class methods" do
        expect(Dog).to respond_to(:count)
        expect(Dog).to respond_to(:all)
        expect(Dog).to respond_to(:find_by_pk)
        expect(Dog).to respond_to(:where)
        expect(Dog).to respond_to(:destroy_all)
      end

      it "raises exceptions" do
        expect{Dog.find_by_pk}.to raise_exception ArgumentError
        expect{Dog.where}.to raise_exception ArgumentError
      end

      it "return model count" do
        expect(Dog.count).to eq(4)
      end

      it "should not find_by_pk record" do
        expect(Dog.find_by_pk(@dog_title)).to be_nil
      end

      it "creates new Dog" do
        dog = Dog.new
        dog.id = 13
        dog.title = @dog_title
        dog.age = 5
        dog.save

        expect(Dog.count).to eq(5)
      end

      it "should find_by_pk record" do
        expect(Dog.find_by_pk(@dog_title)).to be_instance_of Dog
      end

      it "should find by age" do
        dogs = Dog.where({age: 5})
        expect(dogs.count).to eq (2)
        dogs.each do |dog|
          expect(dog).to be_instance_of Dog
          expect(dog.id).to be_kind_of Fixnum
          expect(dog.title).to be_kind_of String
          expect(dog.age).to be_kind_of Fixnum
        end
      end

      it "remove model" do
        expect(Dog.count).to eq(5)

        dog = Dog.find_by_pk(@dog_title)
        dog.destroy

        expect(Dog.count).to eq(4)
      end

      it "removes all" do
        Dog.destroy_all
        expect(Dog.count).to eq(0)
      end

    end

    describe "validations" do

      before :each do
        @cat = Cat.find_by_pk(1);
      end

      it "success age validations" do
        expect(@cat.valid?).to be true
        @cat.age = 2
        expect(@cat.valid?).to be true
        @cat.age = 50
        expect(@cat.valid?).to be true
      end

      it "should not validate age" do
        @cat.age = 51
        expect(@cat.valid?).to be false
        @cat.age = 1
        expect(@cat.valid?).to be false
        @cat.age = '4'
        expect(@cat.valid?).to be false
      end

      it "should not validate title" do
        @cat.title = ''
        expect(@cat.valid?).to be false
        @cat.title = '  '
        expect(@cat.valid?).to be false
      end

      it "should not validate" do
        @cat.age = 51
        expect(@cat.valid?).to be false
      end

      it "should not validate" do
        cat = Cat.new
        expect(cat.valid?).to be false
      end

    end

  end
end