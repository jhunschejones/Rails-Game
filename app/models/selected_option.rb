class SelectedOption < ApplicationRecord
  belongs_to :turn
  belongs_to :option
end
