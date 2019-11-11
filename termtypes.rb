require './console.rb'


class TermTypes
  def initialize
    ## -----*----- コンストラクタ -----*----- ##
    @con = Console.new('./config/console.txt')
    @con.draw('test', 'test')
  end
end


TermTypes.new
