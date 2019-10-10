require "rails_helper"

describe "タスク管理機能", type: :system do
  let(:user_a) { FactoryBot.create(:user, name: "ユーザーA", email: "a@example.com") }
  let(:user_b) { FactoryBot.create(:user, name: "ユーザーB", email: "b@example.com") }
  let!(:task_a) { FactoryBot.create(:task, name: "最初のタスク", user: user_a, due_date: 1.day.since, created_at: 3.day.ago) }

  before do
    visit login_path
    fill_in "メールアドレス", with: login_user.email
    fill_in "パスワード", with: login_user.password
    click_button "ログインする"
  end

  shared_examples_for "ユーザーAが作成したタスクが表示される" do
    it { expect(page).to have_content "最初のタスク" }
  end

  describe "一覧表示機能" do
    context "ユーザーAがログインしているとき" do
      let(:login_user) { user_a }

      it_behaves_like "ユーザーAが作成したタスクが表示される"
    end

    context "ユーザーBがログインしているとき" do
      let(:login_user) { user_b }

      it "ユーザーAが作成したタスクが表示されない" do
        expect(page).to have_no_content "最初のタスク"
      end
    end

    describe "タスク表示順" do
      let(:login_user) { user_a }

      before do
        FactoryBot.create(:task, name: "2番目のタスク", user: user_a, due_date: 2.day.since, created_at: 2.day.ago)
        FactoryBot.create(:task, name: "3番目のタスク", user: user_a, due_date: 3.day.since, created_at: 1.day.ago)
      end

      it "デフォルトで作成日の降順で表示される" do
        visit tasks_path
        within "tbody" do
          task_titles = all(".test-task-name").map(&:text)
          expect(task_titles).to eq %w(3番目のタスク 2番目のタスク 最初のタスク)
        end
      end

      context "終了期日でソートしたとき" do
        it "終了期日の昇順でソートされる" do
          visit tasks_path
          click_link "期日"
          sleep 0.5
          within "tbody" do
            task_titles = all(".test-task-name").map(&:text)
            expect(task_titles).to eq %w(最初のタスク 2番目のタスク 3番目のタスク)
          end
        end

        it "終了期日の降順でソートされる" do
          click_link "期日"
          sleep 0.5
          click_link "期日"
          sleep 0.5
          within "tbody" do
            task_titles = all(".test-task-name").map(&:text)
            expect(task_titles).to eq %w(3番目のタスク 2番目のタスク 最初のタスク)
          end
        end
      end
    end

    describe "ステータス変更", js: true do
      let(:login_user) { user_a }

      it "ステータスの変更ができる" do
        visit tasks_path
        within "#task-#{task_a.id}" do
          click_button "着手中"
        end
        sleep 0.5
        expect(task_a.reload.status).to eq "doing"
      end
    end

    describe "優先度" do
      let(:login_user) { user_a }

      it "優先度の変更ができる" do
        visit tasks_path
        within "#task-#{task_a.id}" do
          find("#test-view-priority").click
          select "高", from: "test-select-priority"
        end
        sleep 0.5
        expect(task_a.reload.priority).to eq "high"
      end
    end

    describe "期日" do
      context "期日に設定された年が現在の年と同じであるとき" do
        let(:login_user) { user_a }
        let!(:nearly_due_task) { FactoryBot.create(:task, name: "期日の近いタスクをテストする", due_date: "#{Time.current.year}-10-10", user: user_a) }

        it "期日の月と日が表示される" do
          visit tasks_path
          within "#task-#{nearly_due_task.id}" do
            expect(page).to have_content("10月10日")
          end
        end
      end

      context "期日に設定された年が現在の年より先であるとき" do
        let(:login_user) { user_a }
        let!(:distant_due_task) { FactoryBot.create(:task, name: "期日の遠いタスクをテストする", due_date: "2100-10-10", user: user_a) }

        it "期日の年月日が表示される" do
          visit tasks_path
          within "#task-#{distant_due_task.id}" do
            expect(page).to have_content("2100年10月10日")
          end
        end
      end
    end

    describe "タスク検索機能" do
      let(:login_user) { user_a }

      before do
        FactoryBot.create(:task, name: "りんごを買う", user: user_a, status: 0, priority: 0, created_at: Time.zone.parse('2019-10-10 15:15:15'))
        FactoryBot.create(:task, name: "バナナを買う", user: user_a, status: 1, priority: 3, created_at: Time.zone.parse('2019-09-10 15:15:15'))
      end

      it "タスク名の部分一致で検索ができること" do
        visit tasks_path
        fill_in "タスク名", with: "買う"
        click_button "検索"
        within "tbody" do
          task_titles = all(".test-task-name").map(&:text)
          expect(task_titles).to contain_exactly("りんごを買う", "バナナを買う")
        end
      end
      it "タスクの登録日時で検索ができること" do
        visit tasks_path
        fill_in "登録日時", with: Time.zone.parse('2019-10-10')
        click_button "検索"
        within "tbody" do
          task_titles = all(".test-task-name").map(&:text)
          expect(task_titles).to eq %w(りんごを買う)
        end
      end
      it "タスクのステータスで検索ができること" do
        visit tasks_path
        select "着手中", from: "ステータス"
        click_button "検索"
        within "tbody" do
          task_titles = all(".test-task-name").map(&:text)
          expect(task_titles).to eq %w(バナナを買う)
        end
      end
      it "タスクの優先度で検索できること" do
        visit tasks_path
        select "高", from: "優先度"
        click_button "検索"
        within "tbody" do
          tasks_titles = all(".test-task-name").map(&:text)
          expect(tasks_titles).to eq %w(バナナを買う)
        end
      end
      it "タスク名、登録日時、ステータス、優先度で検索ができること" do
        visit tasks_path
        fill_in "タスク", with: "買う"
        fill_in "登録日時", with: Time.zone.parse('2019-09-10')
        select "着手中", from: "ステータス"
        select "高", from: "優先度"
        click_button "検索"
        within "tbody" do
          task_titles = all(".test-task-name").map(&:text)
          expect(task_titles).to eq %w(バナナを買う)
        end
      end
    end
  end

  describe "詳細表示機能" do
    context "ユーザーAがログインしているとき" do
      let(:login_user) { user_a }

      before do
        visit task_path(task_a)
      end

      it_behaves_like "ユーザーAが作成したタスクが表示される"
    end
  end

  describe "新規作成機能" do
    let(:login_user) { user_a }

    before do
      visit new_task_path
      fill_in "名称", with: task_name
      click_button "登録する"
    end

    context "新規作成画面で名称を入力したとき" do
      let(:task_name) { "新規作成のタスクを書く" }

      it "正常に登録される" do
        expect(page).to have_selector ".alert-success", text: "新規作成のタスクを書く"
      end
    end

    context "新規作成画面で名称を入力しなかったとき" do
      let(:task_name) { "" }

      it "エラーになる" do
        within "#error_explanation" do
          expect(page).to have_content "名称を入力してください"
        end
      end
    end
  end

  describe "編集機能" do
    let(:login_user) { user_a }

    before do
      visit edit_task_path(task_a)
      fill_in "名称", with: task_name
      click_button "更新する"
    end

    context "編集画面で名称を入力したとき" do
      let(:task_name) { "タスクの更新をする" }

      it "正常に更新される" do
        expect(page).to have_selector ".alert-success", text: "タスクの更新をする"
      end
    end

    context "編集画面で名称を空欄にしたとき" do
      let(:task_name) { "" }

      it "エラーになる" do
        within "#error_explanation" do
          expect(page).to have_content "名称を入力してください"
        end
      end
    end
  end

  describe "削除機能" do
    let(:login_user) { user_a }

    describe "tasks#index" do
      before do
        visit tasks_path
        within "#task-#{task_a.id}" do
          click_link "削除"
        end
        page.driver.browser.switch_to.alert.accept
      end

      it "タスクが削除される" do
        expect(page).to have_content "タスク「最初のタスク」を削除しました。"
      end
    end

    describe "tasks#show" do
      before do
        visit task_path(task_a)
        click_link "削除"
        page.driver.browser.switch_to.alert.accept
      end

      it "タスクが削除される" do
        expect(page).to have_content "タスク「最初のタスク」を削除しました。"
      end
    end
  end
end
