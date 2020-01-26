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
  end


  private


  def print_board(*msg)
    ## -----*----- 画面出力 -----*----- ##
    @cons.draw(*msg)
  end


  def make_outstr(romaji, n_chars=0)
    ## -----*----- 出力文字を生成 -----*----- ##
    # romaji : 出力文字のローマ字配列
    # words  : 入力された文字数
  end
end


if __FILE__ == $0
  obj = SushiTerm.new
  obj.exec
end
