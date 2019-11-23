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
    @quest = read_csv

    exec
  end


  def exec
    ## -----*----- 処理実行 -----*----- ##
    Timer::set_frame_rate(60*100)
    loop do
      @time = 5.0
      quest = @quest.sample
      input = ''

      # タイマー（残り時間）
      Timer::timer {
        @time -= 0.01
        draw(@time, quest[:text], quest[:romaji], input)
      }

      th = Thread.new {
        loop do
          key = STDIN.getch
          exit if key == "\C-c"
          input += key
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


  def timer(framerate)
    ## -----*----- タイマー設定-----*----- ##
    Timer::set_frame_rate(20)
  end


  def read_csv
    ## -----*----- CSV読み込み -----*----- ##
    data = CSV.read('./config/text.csv')
    data.shift

    return data.map { |col| {text: col[0], kana: col[1], romaji: col[1].romaji}}
  end
end


if __FILE__ == $0
  TermTypes.new
end
