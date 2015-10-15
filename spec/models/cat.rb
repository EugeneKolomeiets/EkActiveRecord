class Cat < EkActiveRecord::Core

  attr_accessor :id, :title, :age, :cat_attr

  validates :title, presence: true
  validates :age, min: 2, max:50

end