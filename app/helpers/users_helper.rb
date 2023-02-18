module UsersHelper

  # 引数で与えられたユーザーのアイコン画像を返す
  def icon_for(user, size: 80)
    if user.present? && user.icon_url.present?
      image_tag(user.icon_url, alt: user.name,
                # メールだとbootstrapは効かないので、styleでborder-radiusを指定する。
                size: "#{size}x#{size}", style: 'border-radius: 50%;',
                src: 'Image Not Found',
                onerror: "this.error=null;this.src='#{NOT_FOUND_ICON}'")
    elsif user.present?
      gravatar_for(user, size: size)
    else
      image_tag(NOT_FOUND_ICON,
                alt: t('users.anonymous_user'),
                size: "#{size}x#{size}", style: 'border-radius: 50%;',)
    end
  end

  # 渡されたユーザーのGravatar画像を返す
  def gravatar_for(user, options = { size: 80 })
    size = options[:size]
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar", style: 'border-radius: 50%;')
  end
end
