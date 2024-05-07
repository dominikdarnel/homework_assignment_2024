class Deal < ApplicationRecord
  STATUSES = %w[pending won lost].freeze

  validates :status, inclusion: { in: STATUSES }

  belongs_to :company
end
