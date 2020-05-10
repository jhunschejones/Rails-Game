class Option < ApplicationRecord
  belongs_to :category
  before_save :capitalize_description

  validates :description, length: { minimum: 2, maximum: 500 }

  private

  def capitalize_description
    self.description = self.description.capitalize
  end
end
