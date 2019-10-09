FactoryBot.define do
  factory :task do
    name { "テストを書く" }
    description { "RSpec&Capybara&FactoryBotを準備する" }
    status { 0 }
    due_date { Date.tomorrow}
    priority { 0 }
    user
  end
end
