# -*- coding: utf-8 -*-

require './lib/console.rb'
require './lib/utility.rb'
require 'csv'
require 'io/console'


class SushiTerm
  include Utility

  def initialize
    ## -----*----- コンストラクタ -----*----- ##
    @cons = Console.new './config/outfmt.txt'
    @romaji_table = read_romaji
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


  def to_katakana(romaji)
    ## -----*----- ローマ字->カタカナ変換 -----*----- ##
    # ローマ字の連番配列を指定
    katakana = romaji.map { |c|
      @romaji_table.find {|k,v| v[0] == c[0] }[0]
    }.join.tr('ぁ-ん','ァ-ン')

    return katakana
  end


  def to_romaji(str)
    ## -----*----- ローマ字に変換 -----*----- ##
    str = str.strip
    key = []
    chars = str.chars
    bias = 0
    str.chars.each.with_index do |c, i|
      if @romaji_table.keys.include?(c)
        key << @romaji_table[c]
      else
        tmp = @romaji_table[(chars[i-1-bias] + c).chars.uniq.join]

        if tmp.nil?
          key << [@romaji_table[chars[i+1-bias]][0].chars[0]]
        else
          key[-1] = tmp
          chars[i-1-bias] += c; chars.delete_at(i-bias)
          bias += 1
        end
      end
    end

    return key
  end


  def read_romaji
    ## -----*----- ローマ字対応表 -----*----- ##
    data = CSV.read('./config/romaji.csv')
    data.shift
    romaji = {}
    data.each { |col|
      romaji[col.shift.strip] = col.map {|s| s.strip}
    }

    return romaji
  end
end


if __FILE__ == $0
  obj = SushiTerm.new
  obj.exec
end
