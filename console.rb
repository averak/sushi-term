require './utility.rb'

class Console
  include Utility

  def initialize(file, frame = true)
    ## -----*----- コンストラクタ -----*----- ##
    # デザインフォーマット読み込み
    @plain = File.open(file, 'r').read
    @text = @plain.gsub(/\$[0-9]*/, '$')
    @size = @plain.scan(/\$[0-9]*/).map {|col| col.gsub('$', '').to_i} # それぞれの項目の長さ

    # ウィンドウ幅の取得
    @width = `tput cols`.to_i
    _tag_pos = Struct.new(:x, :y)
    @position = []

    cnt = 0
    @text.split("\n").each_with_index do |line, i|
      next unless line.include?('$')

      # 「$」が含まれる場合
      bias = 0
      line.split('$').each {|col|
        puts col
        @position << _tag_pos.new(count_length(col) + bias, i)
        bias += @position[cnt].x + @size[cnt]
        cnt += 1
      }
    end

    # 画面のクリア
    system('clear')

    # フレーム描画
    if frame
      print_frame
    end
  end

  def draw(*col)
    ## -----*----- 画面描画 -----*----- ##
    raise ArgumentError unless col.length == @size.length

    @size.length.times do |i|
      if @size[i] == 0
        # 空白でパディング
        insert = col[i] + ' ' * (@width - (@position[i][:x] + 6) - count_length(col[i]))
      else
        col[i] = col[i].to_s[0...@size[i]]
        insert = col[i]
      end
      printf("\e[#{@position[i][:x] + 3}C\e[#{@position[i][:y]}B%-#{@size[i]}s\e[#{@text.count("\n")}A\e[#{@width}D", insert)
    end

    STDOUT.flush
  end

  def print_frame
    ## -----*----- フレーム描画 -----*----- ##
    # 「$」を「 」に変換
    field = replace_match(@plain, /\$[0-9]*/) {|match|
      ' ' * match.gsub('$', '').to_i
    }

    lines = field.split("\n") + ['']
    lines[0] = lines[0] + '=' * (@width - count_length(lines[0]))

    # 先頭・末尾に「*」を追加
    lines.map!.with_index do |line, i|
      if i == 0
        line
      else
        unless @width - count_length(line) <= 0
          "*  #{line}" + (' ' * (@width - count_length(line) - 6)) + "  *"
        end
      end
    end

    # 最終列を「=」列に
    lines << '=' * @width

    # 描画
    print "#{lines.join}\e[#{lines.length}A\e[#{@width}D"
  end

  def count_length(str)
    ## -----*----- 文字列の長さ取得 -----*----- ##
    # 半角：1，全角：2 としてカウント
    str.length + str.chars.reject(&:ascii_only?).length
  end
end


if __FILE__ == $0
  obj = Console.new('./config/console.txt')
  loop do
    obj.draw('I', 'am')
    sleep 1
    obj.draw('She', 'a girl')
    sleep 1
  end
end
