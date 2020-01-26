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
      # 変数設定
      @time = @limit.dup         # 残り時間
      timer 60*100               # 残り時間のタイマー
      @quest = @sentences.sample # 現在の問題文
      @quest[:input] = ['']      # 入力されたローマ字の配列
      @quest[:i_romaji] = Array.new(@quest[:romaji].length, 0)
      collect = Marshal.load(Marshal.dump(@quest[:romaji]))

      key_input = Thread.new {
        # キー入力
        while @time > 0.0
          key = STDIN.getch
          exit if key == "\C-c" || key == "\e"

          b_same = false
          collect[0].each_with_index { |romaji, i|
            # 正しいキーが入力された場合
            unless romaji.slice(0).nil?
              if key==romaji.slice(0) || key==romaji.slice(0).upcase
                unless b_same
                  @quest[:input][-1] += key
                  @quest[:i_romaji][@quest[:input].length-1] = i
                  collect[0][i].slice!(0)  unless collect[0][i].nil?
                  b_same = true
                end
              end
            end

            # カタカナ１文字分入力し終わった場合
            if romaji == ''
              collect.shift
              @quest[:input] << ''
            end
            # 入力終了した場合
            if collect == []
              @time = 0.0
              break
            end
          }
        end
      }

      # タイムリミット -> 次の問題へ
      loop do
        sleep 0.01
        break if @time <= 0.0
      end
      # サブスレッドをkill
      Timer::exit
      key_input.kill
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
        build_outstr(@quest[:romaji], @quest[:input].join.length),
        @romaji.to_katakana(@quest[:input])
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
    ret = romaji.map.with_index { |s, i|
      s[@quest[:i_romaji][i]]
    }.join
    #     ret = romaji.map.with_index { |s, i|
    #       if i < n_chars-1
    #         "\e[30m#{s[@quest[:i_romaji][i]]}\e[0m"
    #       else
    #         s[@quest[:i_romaji][i]]
    #       end
    #     }.join

    ret
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
