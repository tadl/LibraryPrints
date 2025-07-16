class Category < ApplicationRecord
  has_many :printable_models, dependent: :destroy
end
