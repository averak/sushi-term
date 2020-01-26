# -*- coding: utf-8 -*-

require 'csv'


class Romaji
  def initialize(file)
    ## -----*----- コンストラクタ -----*----- ##
    # ローマ字対応を記載したcsvファイルを指定
    data = CSV.read(file)
    data.shift
    @romaji = {}
    data.each { |col|
      @romaji[col.shift.strip] = col.map {|s| s.strip}
    }
  end


  def to_romaji(str)
    ## -----*----- ローマ字に変換 -----*----- ##
    str = str.tr('ァ-ン', 'ぁ-ん',).strip
    key = []
    chars = str.chars
    bias = 0
    str.chars.each.with_index do |c, i|
      if @romaji.keys.include?(c)
        key << @romaji[c]
      else
        tmp = @romaji[(chars[i-1-bias] + c).chars.uniq.join]

        if tmp.nil?
          key << [@romaji[chars[i+1-bias]][0].chars[0]]
        else
          key[-1] = tmp
          chars[i-1-bias] += c; chars.delete_at(i-bias)
          bias += 1
        end
      end
    end

    return key
  end


  def to_katakana(romaji)
    ## -----*----- ローマ字->カタカナ変換 -----*----- ##
    # ローマ字の連番配列を指定
    katakana = romaji.map.with_index { |c, i|
      search = @romaji.find {|k,v| v.include? c }
      if search.nil?
        tmp = c
        if i+1 < romaji.length
          if c == romaji[i+1][0]
            tmp = 'っ'
          end
        end
        tmp
      else
        search[0]
      end
    }.join.tr('ぁ-ん','ァ-ン')

    return katakana
  end
end
;
