require 'rails_helper'

RSpec.describe Task, type: :model do
  it "当日以降の期限は有効であること" do
    task = FactoryBot.build(:task, due_date: Date.today)
    expect(task.valid?).to be true
  end
  it "過去の日付の期限は無効であること" do
    task = FactoryBot.build(:task, due_date: Date.yesterday)
    task.valid?
    expect(task.errors[:due_date]).to include("に過去の日付は指定できません")
  end
  it "期日が過ぎている場合でも他の属性の更新ができること" do
    task = FactoryBot.create(:task, due_date: Date.today)
    travel_to Date.tomorrow do
      task.name = "タスク名を変更する"
      expect(task.valid?).to be true
    end
  end
end
