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