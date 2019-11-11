# -*- coding: utf-8 -*-

module Utility
  def shaping_string(str)
    ## -----*----- 文字例の整形 -----*----- ##
    # 余計な改行，空白を全て削除
    str = str.to_s
    return str.gsub(" ", ' ').squeeze(' ').gsub("\n \n", "\n").gsub("\n ", "\n").gsub("\r", "\n").squeeze("\n").gsub("\t", "").strip
  end

  def include_chars?(str, *char)
    ## -----*----- 文字列に特定の文字（複数）が1つでも含まれているのか？ -----*----- ##
    str = str.to_s
    ret = false
    char.each {|c| ret = true if str.include?(c)}
    return ret
  end

  def weight_random(min, max, n, rate)
    ## -----*----- 重み付き乱数生成（min~max） -----*----- ##
    # rate：n（min <= n <= max）の発生確率（0 < rate <= 1）
    if rand <= rate
      return n
    else
      range = (min..max).to_a; range.delete(n)
      return range.sample
    end
  end

  def parse_opts(*opts)
    ## -----*----- 実行オプション -----*----- ##
    ARGV.each do |opt|
      if opts.include?(opt)
        yield
        return
      end
    end
  end

  def replace_match(str, pattern)
    ## -----*----- 正規表現にマッチした箇所を置換 -----*----- ##
    str = str.to_s
    str.scan(pattern).each do |sub|
      str.gsub!(sub, yield(sub))
    end
    return str
  end

  def read_csv(file)
    ## -----*----- csvファイル読み込み -----*----- ##
    require 'csv'
    table = CSV.table(file, encoding: "UTF-8")
    return table
  end

  def read_json(file)
    ## -----*----- Jsonファイル読み込み -----*----- ##
    require 'json'
    File.open(file, 'r') {|file|
      return JSON.load(file)
    }
  end
end


module Timer
  def set_frame_rate(time)
    ## -----*----- フレームレートの初期化 -----*----- ##
    @frame_rate = time
  end

  def timer(join: false, sleep: true)
    ## -----*----- タイマー設定（サブスレッド） -----*----- ##
    @th = Thread.new {
      loop do
        yield
        sleep 60.0 / @frame_rate if sleep
      end
    }
    @th.join if join
  end

  def exit
    ## -----*----- タイマー処理終了 -----*----- ##
    @th.kill
  end

  module_function :set_frame_rate, :timer, :exit
end