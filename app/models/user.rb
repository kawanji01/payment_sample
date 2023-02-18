class User < ApplicationRecord
  # 支払い手段・クレカ
  has_one :customer, dependent: :destroy
  # サブスク
  has_many :subscriptions, dependent: :destroy
  # 都度払い
  has_many :unit_purchases, dependent: :destroy



  # user_idをランダムな数字にする /gem public_uid
  generate_public_uid generator: PublicUid::Generators::NumberSecureRandom.new
  mount_uploader :icon, IconUploader
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }
  # has_secure_passwordは、'bcrypt'を利用してpassword_digestを生成したり、authenticateメソッドを利用できるようにする。参照：https://railstutorial.jp/chapters/modeling_users?version=5.1#sec-creating_and_authenticating_a_user
  # has_secure_password validations: true
  has_secure_password validations: false
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  validates :profile, length: { maximum: 500 }, allow_nil: true


  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
             BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self.id, self.activation_token).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def lang_code
    'ja'
  end



  # 有料会員かどうか確認する。
  def verify_premium_member?
    # Stripeで契約したか？
    customer.subscriptions.present?
  end

  # public_uid
  def self.find_param(param)
    find_by! public_uid: param
  end

  def to_param
    public_uid
  end

  def g_public_uid
    update(public_uid: SecureRandom.hex(5))
  end

  private

  # メールアドレスをすべて小文字にする
  def downcase_email
    self.email = email.downcase
  end

  # 有効化トークンとダイジェストを作成および代入する
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end


end
