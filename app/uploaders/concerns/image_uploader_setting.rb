module ImageUploaderSetting
  extend ActiveSupport::Concern

  included do

    # Choose what kind of storage to use for this uploader:
    if Rails.env.production?
      storage :fog
    else
      storage :file
    end

    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    # アップロードファイルの保存先ディレクトリは上書き可能
    # 下記はデフォルトの保存先
    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    # Add a white list of extensions which are allowed to be uploaded.
    # For images you might use something like this:
    # アップロード可能な拡張子のリスト
    def extension_whitelist
      %w[jpg jpeg gif png]
    end

  end

end
