class Lang < ApplicationRecord
  # 言語コードを言語番号に変換して返す / convert lang_code into lang_number and return lang_number
  # 言語コードを言語番号に変換する処理は、すべて必ずこのメソッドを使うこと！ / You have to use it in all processes to convert lang_code to lang_number.
  def self.convert_code_to_number(lang_code)
    hash = Languages::CODE_MAP.find { |k, v| k == lang_code }
    return if hash.blank?

    hash.second
  end

  # 言語番号を言語コードに変換して返す / convert lang_number into lang_code and return lang_code
  # 言語番号を言語コードに変換する処理は、すべて必ずこのメソッドを使うこと！ / You have to use it in all processes to convert lang_number to code..
  def self.convert_number_to_code(number)
    hash = Languages::CODE_MAP.find { |k, v| v == number }
    return if hash.blank?

    hash.first
  end


  # "en-j3PyPqV-e1s"とか"zh-Hans-419"といった値（主に手動字幕で用いられる）を、DiQtで扱えるlang_codeに変換する。
  def self.convert_value_to_code(value)
    lang_code = nil
    if Lang.lang_code_supported?(value)
      # 一度言語コードを番号に変換してからコードに再変換することで、DiQt の対応している言語コードに変換する。
      lang_number = Lang.convert_code_to_number(value)
      lang_code = Lang.convert_number_to_code(lang_number)
    elsif Lang.lang_code_supported?(value.sub('auto-', ''))
      lang_code = value.sub('auto-', '')
    elsif Lang.lang_code_supported?(value.sub(/-.*/, ''))
      #  "en-j3PyPqV-e1s" のような言語コードがあった場合に、enとして扱う。問題が起きた動画: https://www.youtube.com/watch?v=cyFM2emjbQ8&list=PLjxrf2q8roU3wk7CDw4RfV3mEwOJbjx1k&index=7
      code = value.sub(/-.*/, '')
      lang_number = Lang.convert_code_to_number(code)
      lang_code = Lang.convert_number_to_code(lang_number)
    elsif Lang.lang_code_supported?(value.match(/^[^-]+-[^-]+/)[0])
      # "zh-Hans-419" のような言語コードがあった場合に、zh-Hans として扱う。
      code = value.match(/^[^-]+-[^-]+/)[0]
      lang_number = Lang.convert_code_to_number(code)
      lang_code = Lang.convert_number_to_code(lang_number)
    end
    lang_code
  end



  # 引数のテキストの言語コードを返す
  def self.return_lang_data(text)
    url = URI.parse('https://translation.googleapis.com/language/translate/v2/detect')
    params = {
      q: text,
      key: ENV['GOOGLE_CLOUD_API_KEY']
    }
    url.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(url)
    json = res.body
    # レスポンスのjsonの言語のパラメータをパースする
    JSON.parse(json)['data']['detections'][0][0]['language']
  end

  # 引数のテキストの言語が何であるか、DiQt全体で統一している言語番号で返す。
  def self.return_lang_number(text)
    convert_code_to_number return_lang_data(text)
  end

  # サポートされている言語コードか？
  def self.lang_code_supported?(lang_code)
    convert_code_to_number(lang_code).present?
  end

  # サポートされていない言語コードか？
  def self.lang_code_unsupported?(lang_code)
    !lang_code_supported?(lang_code)
  end


  # 言語コードを引数に、該当するBCP47の言語コードの一覧を取得する。
  # BCP47はspeech-to-textのlanguage_codeとして渡す必要がある。
  def self.find_all_bcp47(lang_code)
    array = Languages::BCP47_MAP.find_all { |k, v| v == lang_code }
    return if array.blank?

    array.map { |a| a[0] }
  end

  # BCP47を言語コードに変換する
  def self.convert_bcp47_to_code(bcp47)
    hash = Languages::BCP47_MAP.find { |k, v| k == bcp47 }
    return if hash.blank?

    hash.second
  end

  # BCP47を言語番号に変換する
  def self.convert_bcp47_to_number(bcp47)
    code = Lang.convert_bcp47_to_code(bcp47)
    Lang.convert_code_to_number(code)
  end



end

