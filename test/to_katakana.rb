require './lib/romaji.rb'

str = 'いんくじぇっとぷりんたー'
romaji = Romaji.new './config/romaji.csv'
tmp = romaji.to_romaji str
tmp.map! {|arr| arr[0]}
p tmp
p romaji.to_katakana tmp
