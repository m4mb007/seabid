class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :bids, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :plate_numbers, through: :bids
  
  validates :email, presence: true, uniqueness: true
  validates :encrypted_password, presence: true
end
