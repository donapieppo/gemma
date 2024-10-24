FactoryBot.define do
  sequence :random_string do |n|
    rand_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    rand_max = rand_chars.size
    ret = ""
    11.times { ret << rand_chars[rand(rand_max)] }
    ret
  end

  factory :supplier do
    name { generate :random_string }
    pi { generate :random_string }
  end
end
