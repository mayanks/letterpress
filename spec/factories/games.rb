# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :game do
    letters "MyText"
    player_a_id 1
    player_b_id 1
    state 1
    player_a_score 1
    player_b_score 1
  end
end
