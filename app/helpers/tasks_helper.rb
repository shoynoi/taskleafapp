module TasksHelper
  def format_due_date(due_date)
    return unless due_date
    if due_date.year == Time.current.year
      l due_date, format: :short
    else
      l due_date
    end
  end
end
