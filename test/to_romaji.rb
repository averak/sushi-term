require 'csv'


str = 'インクジェットプリンター'

romaji = CSV.read('./config/romaji.csv')
romaji.shift
romaji.map! { |col|
  {col.shift.strip => col.map {|s| s.strip}}
}
p str
p romaji
