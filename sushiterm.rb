# -*- coding: utf-8 -*-

require './console.rb'
require './utility.rb'
require 'csv'
require 'io/console'


class SushiTerm
  include utility

  def initialize
    ## -----*----- コンストラクタ -----*----- ##
    @cons = Console.new './config/outfmt.txt'
  end
end
