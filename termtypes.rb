require './console.rb'
require './utility.rb'
require 'csv'


class TermTypes
  include Utility

  def initialize
    ## -----*----- コンストラクタ -----*----- ##
    @con = Console.new('./config/console.txt')
    @quest = read_csv


    ## ===== test ===============
    loop do
      quest = @quest.sample
      draw(quest[:text], quest[:kana], '')
      sleep 0.5
    end
    ## ==========================

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

    return data.map { |col| {text: col[0], kana: col[1]}}
  end
end


if __FILE__ == $0
  TermTypes.new
end
