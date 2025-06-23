# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Common scopes available to all models
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest, -> { order(created_at: :asc) }

  # Common methods available to all models
  def created_today?
    created_at >= Date.current.beginning_of_day
  end

  def updated_today?
    updated_at >= Date.current.beginning_of_day
  end

  def age_in_days
    (Date.current - created_at.to_date).to_i
  end

  def to_param
    id.to_s
  end
end
