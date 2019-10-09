class Api::Tasks::PrioritiesController < ApplicationController
  def show
    @task = current_user.tasks.find(params[:task_id])
  end

  def update
    task = current_user.tasks.find(params[:task_id])
    if task.update!(priority: params[:priority])
      render json: task, status: :ok
    else
      render json: task.errors, status: :unprocessable_entity
    end
  end
end
