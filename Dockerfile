# 参考
# 公式チュートリアル：https://docs.docker.com/samples/rails/
# 既存アプリにDockerを導入：https://qiita.com/kenz-dev/items/b9e716204e0cd0cea447
# https://qiita.com/azul915/items/5b7063cbc80192343fc0

#　参考：　https://qiita.com/fuku_tech/items/dc6b568f7f34df10cae7
FROM ruby:2.7.2

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y postgresql-client --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

WORKDIR /myproject

ADD Gemfile /myproject/Gemfile
ADD Gemfile.lock /myproject/Gemfile.lock

# RUN gem install bundler # きちんとバージョンを指定していない。
# localとimage内でのbundlerのversionに乖離があるとエラーが起きる。開発環境で動いたとしてもherokuの本番環境でアプリをクラッシュさせる。
# 参考： https://qiita.com/tanakaworld/items/468d421eca58576006fb
ENV BUNDLER_VERSION 2.1.4
RUN gem update --system \
    && gem install bundler -v $BUNDLER_VERSION \
    && bundle install -j 4
RUN bundle install

ADD . /myproject