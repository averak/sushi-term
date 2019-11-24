require 'csv'


str = 'ほしのないよるのそら'

data = CSV.read('./config/romaji.csv')
data.shift
romaji = {}
data.each { |col|
  romaji[col.shift.strip] = col.map {|s| s.strip}
}


key = []
str.chars.each do |c|
  if romaji.keys.include?(c)
    key << romaji[c]
  else
    key << [c]
  end
end
p str
p key
