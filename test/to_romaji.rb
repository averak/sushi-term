require 'csv'


str = 'ぽけっとてぃっしゅ'

data = CSV.read('./config/romaji.csv')
data.shift
romaji = {}
data.each { |col|
  romaji[col.shift.strip] = col.map {|s| s.strip}
}


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
p str
p key.map {|c| c[0]}.join
