class Admin < ApplicationRecord
  has_many :customers
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
