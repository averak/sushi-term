require './lib/console.rb'
require './lib/utility.rb'
require 'csv'
require 'romaji'
require 'romaji/core_ext/string'
require 'io/console'


class TermTypes
  include Utility

  def initialize
    ## -----*----- コンストラクタ -----*----- ##
    @con = Console.new('./config/outfmt.txt')
    @limit = 5.0

    exec
  end


  def exec
    ## -----*----- 処理実行 -----*----- ##
    Timer::set_frame_rate(60*100)
    loop do
      @time = @limit.dup
      quest = read_csv().sample
      input = ''
      output = make_output(quest[:romaji])

      # タイマー（残り時間）
      Timer::timer {
        @time -= 0.01
        draw(timebar(@time), quest[:text], output, input.kana)
      }

      th = Thread.new {
        collect = Marshal.load(Marshal.dump(quest[:romaji]))

        # キー入力
       while @time > 0.0
          key = STDIN.getch
          exit if key == "\C-c" || key == "\e"
          char_index = 0

          flag = true
          begin
            collect[0].each.with_index do |c, i|
              unless c.slice(0).nil?
                if key == c.slice(0) || key == c.slice(0).upcase
                  if flag
                    input += key
                    collect[0][i].slice!(0) unless collect[0][i].nil?
                    #quest[:romaji][char_index][0] = quest[:romaji][char_index][i]
                    flag = false
                  end
                end
              end

              if c == ''
                collect.shift
                char_index += 1
              end
              if collect == []
                @time = 0.0
                break
              end

              # 出力文字
              #output = make_output(quest[:romaji], quest[:romaji].length - collect.length)
              output = make_output(quest[:romaji], input.length)
            end
          rescue => e
            p e
            @time = 0.0
            break
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


  def make_output(romaji, words=0)
    ## -----*----- 出力文字の生成 -----*----- ##
    cnt = 0
    ret = romaji.map { |s|
      s[0].chars.map { |c|
        cnt += 1
        if cnt <= words
          "\e[30m#{c}\e[0m"
        else
          c
        end
      }.join
    }

    return ret.join
  end


  def draw(*msg)
    ## -----*----- 画面出力 -----*----- ##
    @con.draw(*msg)
  end


  def timebar(time)
    ## -----*----- 残り時間のバー表示 -----*----- ##
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
    romaji = read_romajij
    str = str.strip
    key = []
    chars = str.chars
    bias = 0
    str.chars.each.with_index do |c, i|
      if romaji.keys.include?(c)
        key << romaji[c]
      else
        tmp = romaji[(chars[i-1-bias] + c).chars.uniq.join]

        if tmp.nil?
          key << [romaji[chars[i+1-bias]][0].chars[0]]
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

