require './console.rb'
require './utility.rb'
require 'csv'
require 'romaji'
require 'romaji/core_ext/string'
require 'io/console'


class TermTypes
  include Utility

  def initialize
    ## -----*----- コンストラクタ -----*----- ##
    @con = Console.new('./config/console.txt')
    @romaji = read_romajij

    exec
  end


  def exec
    ## -----*----- 処理実行 -----*----- ##
    Timer::set_frame_rate(60*100)
    loop do
      @time = 5.0
      quest = read_csv().sample
      input = ''

      # タイマー（残り時間）
      Timer::timer {
        @time -= 0.01
        romaji = quest[:romaji].map {|c| c[0]}.join
        draw(timebar(@time), quest[:text], romaji, input)
      }

      th = Thread.new {
        collect = quest[:romaji].map {|c| c[0]}.join
        tmp = collect.dup
        cnt = 0

        # キー入力
        loop do
          key = STDIN.getch
          exit if key == "\C-c" || key == "\e"

          if key == collect.slice(0)
            input += key
            input = input.kana
            collect.slice!(0)
            cnt += 1

            str = tmp.chars.map.with_index do |c, i|
              if i <= cnt - 1
                "\e[30m#{c}\e[0m"
              else
                c
              end
            end

            quest[:romaji] = str.join

            @time = 0.0 if collect == ''
          end
        end
      }

      loop do
        sleep 0.01
        break if @time <= 0.0
      end

      Timer::exit
      th.kill
    end
  end


  def draw(*msg)
    ## -----*----- 画面出力 -----*----- ##
    @con.draw(*msg)
  end


  def timebar(time)
    ## -----*----- 残り時間のバー表示 -----*----- ##
    width = `tput cols`.to_i - 50
    return '' if (width * time / 5.0).to_i <= 0.0

    bar = '■' * (width * time / 5.0).to_i
    if time > 3.3
      return "\e[32m#{bar}\e[0m"
    elsif time > 1.7
      return "\e[33m#{bar}\e[0m"
    else
      return "\e[31m#{bar}\e[0m"
    end
  end


  def read_csv
    ## -----*----- CSV読み込み -----*----- ##
    data = CSV.read('./config/text.csv')
    data.shift

    return data.map { |col| {text: col[0].strip,
                             kana: col[1].strip, romaji: to_romaji(col[1])}
    }
  end


  def read_romajij
    ## -----*----- ローマ字対応表 -----*----- ##
    data = CSV.read('./config/romaji.csv')
    data.shift
    romaji = {}
    data.each { |col|
      romaji[col.shift.strip] = col.map {|s| s.strip}
    }

    return romaji
  end


  def to_romaji(str)
    ## -----*----- ローマ字に変換 -----*----- ##
    str = str.strip
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
end


if __FILE__ == $0
  TermTypes.new
end
