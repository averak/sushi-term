# -*- coding: utf-8 -*-

require './lib/console.rb'
require './lib/utility.rb'
require './lib/romaji.rb'
require 'csv'
require 'io/console'


class SushiTerm
  include Utility

  def initialize
    ## -----*----- コンストラクタ -----*----- ##
    @cons = Console.new './config/outfmt.txt'
    @romaji = Romaji.new './config/romaji.csv'
    @limit = 5.0

    # 問題文を読み取り
    @sentences = CSV.read('./config/text.csv')
    @sentences.shift
    @sentences.map! { |col|
      {
        text: col[0].strip,
        kana: col[1].strip,
        romaji: @romaji.to_romaji(col[1])
      }
    }
  end


  def exec
    ## -----*----- 処理実行 -----*----- ##
    loop do
      @time = @limit.dup         # 残り時間
      timer 60*100               # 残り時間のタイマー
      @quest = @sentences.sample # 現在の問題文
      @quest[:input] = ''
    end
  end


  private


  def timer(frame_rate)
    ## -----*----- タイマー -----*----- ##
    Timer::set_frame_rate(frame_rate)
    Timer::timer {
      @time -= 0.01
      # 描画
      print_board(
        build_timebar(@time),
        @quest[:text],
        build_outstr(@quest[:romaji]),
        @quest[:input]
      )
    }
  end


  def print_board(*msg)
    ## -----*----- 画面出力 -----*----- ##
    @cons.draw(*msg)
  end


  def build_outstr(romaji, n_chars=0)
    ## -----*----- 出力文字を生成 -----*----- ##
    # romaji : 出力文字のローマ字配列
    # words  : 入力された文字数
  end


  def build_timebar(time)
    ## -----*----- 残り時間のバー生成 -----*----- ##
    width = `tput cols`.to_i - 18
    return '' if (width * time / @limit).to_i <= 0.0

    bar = '■' * (width * time / @limit).to_i

    if time > @limit * 2/3
      return "\e[32m#{bar}\e[0m"
    elsif time > @limit / 3
      return "\e[33m#{bar}\e[0m"
    else
      return "\e[31m#{bar}\e[0m"
    end
  end
end


if __FILE__ == $0
  obj = SushiTerm.new
  obj.exec
end
