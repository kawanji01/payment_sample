class Plan < ApplicationRecord
  # belongs_to :user, optional: true
  has_many   :subscriptions, dependent: :destroy
  # Planに登録しているユーザー一覧
  has_many :subscribers, through: :subscriptions, source: :user
  # 追加料金
  has_one :unit
  validates :stripe_price_id, presence: true
  # before_destroy :delete_stripe_plan, prepend: true

  #validates :nickname, presence: true
  # validates :amount,   presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 100, less_than_or_equal_to: 10_000 }
  #validates :trial_period_days, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 40 }

  def set_attributes_by_stripe_id
    stripe_plan = Stripe::Plan.retrieve(self.stripe_price_id) rescue nil
    self.currency = stripe_plan&.currency
    self.interval = stripe_plan&.interval
    self.usage_type = stripe_plan&.usage_type
  end

  def unix_time_trial_end
    return if trial_period_days.blank?

    end_date_str = Time.now.next_day(self.trial_period_days).to_s
    Time.parse(end_date_str).to_i
  end


  # 無料お試し期間
  def trial_period_days_count
    if trial_period_days.present? && trial_period_days > 1
      trial_period_days
    else
      nil
    end
  end


  def self.monthly_school
    find_by(reference_number: 1)
  end

end
