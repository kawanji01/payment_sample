Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  scope '(:locale)', locale: /#{I18n.available_locales.map(&:to_s).join('|')}/ do
    root to: 'static_pages#home'
    post '/create-checkout-session', to: 'static_pages#create-checkout-session'


    mount Sidekiq::Web => '/sidekiq'
    mount ActionCable.server => '/cable'

    # APIとサービスの「認証情報」の設定
    get '/auth/google_oauth2/callback', to: 'static_pages#home'
    get  '/signup',  to: 'users#new'
    get    '/login',   to: 'sessions#new'
    post   '/login',   to: 'sessions#create'
    delete '/logout',  to: 'sessions#destroy'

    # 資料請求
    get '/catalog_request', to: 'static_pages#catalog_request'

    # 2020/10/21 letter_opener 導入
    if Rails.env.development?
      mount LetterOpenerWeb::Engine, at: '/letter_opener'
    end

    resources :users do
      member do
        get :payment_setting
        get :invoices
      end
    end
    resources :account_activations, only: [:edit]
    resources :password_resets,     only: [:new, :create, :edit, :update]

    resources :plans do
      collection do
        get :introduction
      end
    end
    resources :units

    # 支払い方法
    resources :customers do
      member do
        #支払い方法の削除の確認
        get :delete_confirmation
      end
      collection do
        get :fix_payment_method
      end
    end

    # 定期課金
    resources :subscriptions do
      collection do
        get :checkout
        get :success
      end
      member do
        patch :cancel
      end
    end

    # 都度購入
    resources :unit_purchases do
      collection do
        get :checkout
        get :success
      end
    end

    resources :webhook do
      collection do
        post :stripe
      end
    end


  end
end
