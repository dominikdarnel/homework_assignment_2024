class Company < ApplicationRecord
  has_many :deals

  paginates_per 10
end
