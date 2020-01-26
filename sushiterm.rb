# -*- coding: utf-8 -*-

require './console.rb'
require './utility.rb'
require 'csv'
require 'io/console'


class SushiTerm
  include utility

  def initialize
    ## -----*----- コンストラクタ -----*----- ##
    @cons = Console.new './config/outfmt.txt'
    @limit = 5.0
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
