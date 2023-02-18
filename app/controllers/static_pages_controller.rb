class StaticPagesController < ApplicationController
  before_action :extract_user_language

  def home
    @user = current_user
  end
  

  def catalog_request
    #channel = "#webhook-test"
    channel = "#inquiry"
    inquiry = params[:inquiry]
    content = "お名前: #{params[:name]} \n
Email: #{params[:email]} \n
電話番号： #{params[:phone]} \n
お問い合わせ内容： #{params[:inquiry]} \n
メッセージ： #{params[:message]}"
    notifier = Slack::Notifier.new(
      ENV['WEBHOOK_URL'],
      channel: channel,
      username: inquiry,
      )
    a_ok_note = {
      title: inquiry,
    }
    notifier.post text: content,
                  icon_url: DIQT_ICON,
                  attachments: [a_ok_note]
    flash[:success] = "資料請求を承りました。この度はご興味を持っていただき、誠にありがとうございます！"
    redirect_to root_url
  end



  private
  
  def extract_user_language
    available = %w[ja en]
    @user_language = http_accept_language.preferred_language_from(available)
  end

end
