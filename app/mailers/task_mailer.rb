class TaskMailer < ApplicationMailer
  default from: "taskleaf@example.com"

  def creation_email(task)
    @task = task
    mail(
      subject: "タスク作成完了メール",
      to: "user@example.com",
    )
  end
end
