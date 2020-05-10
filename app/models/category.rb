class Category < ApplicationRecord
  belongs_to :game
  has_many :options
  before_save :capitalize_title

  validates :title, length: { minimum: 2, maximum: 100 }

  private

  def capitalize_title
    self.title = self.title.capitalize
  end
end
