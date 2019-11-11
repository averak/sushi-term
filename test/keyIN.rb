require 'io/console'

i = 0
while (key = STDIN.getch) != "\C-c"
  puts " #{i += 1}: #{key.inspect} キーが押されました。"
end
