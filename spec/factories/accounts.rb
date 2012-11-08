# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :account do
    name "MyString"
    number "MyString"
    branch "MyString"
    balance 1
  end
end
