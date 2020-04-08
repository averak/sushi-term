#! /usr/bin/env ruby

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
    @limit = 10.0

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
      @next=false
      timer 60*100               # 残り時間のタイマー
      @quest = @sentences.sample # 現在の問題文
      @quest[:input] = ['']      # 入力されたローマ字の配列
      collect = Marshal.load(Marshal.dump(@quest[:romaji]))
      cnt = [0, Array.new(@quest[:romaji][0].length, 0)]

      key_input = Thread.new {
        # キー入力
        while @time > 0.0 && collect != []
          next  if @next
          key = STDIN.getch
          exit if key == "\C-c" || key == "\e"

          b_same = false
          collect[0].length.times { |i|
            # 正解キーが入力された場合
            if key==@quest[:romaji][cnt[0]][i][cnt[1][i]] || key==@quest[:romaji][cnt[0]][i][cnt[1][i]].upcase
              unless b_same
                @quest[:input][-1] += key.downcase
                b_same = true
              end
              collect[0][i].slice!(0)
              cnt[1][i] += 1
            end

            # カタカナ１文字分入力し終わった場合
            if collect[0][i] == ''
              collect.shift
              cnt[0] += 1
              cnt[1] = Array.new(collect[0].length, 0)  unless collect[0].nil?
              @quest[:input] << ''

              # 入力終了した場合
              @next = true  if collect == []

              break
            end
          }
        end
      }

      # タイムリミット -> 次の問題へ
      loop do
        sleep 0.01
        break if @time <= 0.0 || @next
      end
      # サブスレッドをkill
      sleep 0.3
      Timer::exit
      key_input.kill
      @next = false
    end
  end


  private


  def timer(frame_rate)
    ## -----*----- タイマー -----*----- ##
    Timer::set_frame_rate(frame_rate)
    t1 = Time.now
    t2 = Time.now
    Timer::timer {
      t2 = Time.now
      @time -= t2-t1  unless @next
      t1 = Time.now

      katakana = @romaji.to_katakana(@quest[:input])
      # 入力配列へのキー追加に失敗している際のケア
      if !katakana.match(/[a-z]/).nil? && @quest[:input][-1]==''
        index = @quest[:input].length-2
        @quest[:input][index] = @quest[:romaji][index][0]
      end

      # 描画
      print_board(
        build_timebar(@time),
        @quest[:text],
        build_outstr(@quest[:romaji], @quest[:input].join.length),
        katakana
      )
    }
  end


  def print_board(*msg)
    ## -----*----- 画面出力 -----*----- ##
    @cons.draw(*msg)
  end


  def build_outstr(romaji, n_chars=0)
    ## -----*----- 出力文字を生成 -----*----- ##
    # romaji  : 出力文字のローマ字配列
    # n_chars : 入力された文字数
    ret = romaji.map.with_index { |s, i|
      if @quest[:input].length > i
        s.find { |c| c.include?(@quest[:input][i])}
      else
        s[0]
      end
    }.join
    ret = ret.chars.map.with_index { |c, i|
      if i < n_chars
        "\e[30m#{c}\e[0m"
      else
        c
      end
    }.join

    ret
  end


  def build_timebar(time)
    ## -----*----- 残り時間のバー生成 -----*----- ##
    width = `tput cols`.to_i - 18
    return '' if (width * time / @limit).to_i <= 0.0

    bar = '■' * (width * time / @limit).to_i

    if @next
      return "\e[30m#{bar}\e[0m"
    elsif time > @limit * 2/3
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
