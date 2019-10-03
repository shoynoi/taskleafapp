class Task < ApplicationRecord
  has_one_attached :image
  enum status: { pending: 0, doing: 1, done: 2 }
  validates :name, presence: true, length: { maximum: 30 }
  validates :status, inclusion: { in: Task.statuses.keys }
  validate :due_date_cannot_be_in_the_past, if: :new_or_due_date_changed?
  validate :validate_name_not_including_comma
  belongs_to :user

  scope :recent, -> { order(created_at: :desc) }
  scope :sort_by_due_date_not_null_asc, -> { order("due_date ASC NULLS LAST") }
  scope :sort_by_due_date_not_null_desc, -> { order("due_date DESC NULLS LAST") }

  def self.csv_attributes
    %w[name description created_at updated_at]
  end

  def self.generate_csv
    CSV.generate(headers: true) do |csv|
      csv << csv_attributes
      all.each do |task|
        csv << csv_attributes.map { |attr| task.send(attr) }
      end
    end
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      task = new
      task.attributes = row.to_hash.slice(*csv_attributes)
      task.save!
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name created_at due_date]
  end

  def self.ransackable_association(auth_object = nil)
    []
  end
  private

  def validate_name_not_including_comma
    errors.add(:name, "にカンマを含めることはできません") if name&.include?(",")
  end

  def due_date_cannot_be_in_the_past
    errors.add(:due_date, "に過去の日付は指定できません") if due_date&.past?
  end

  def new_or_due_date_changed?
    new_record? || will_save_change_to_due_date?
  end
end
