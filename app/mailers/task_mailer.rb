class TaskMailer < ApplicationMailer
  default from: "taskleaf@example.com"

  def creation_email(task, user)
    @task = task
    mail(
      subject: "タスク作成完了メール",
      to: user.email
    )
  end
end
