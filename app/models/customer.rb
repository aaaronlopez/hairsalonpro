class Customer < ApplicationRecord
  belongs_to :admin
  has_many :appointments
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, presence: true, uniqueness: true
end
