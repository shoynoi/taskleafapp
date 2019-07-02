class Task < ApplicationRecord
  has_one_attached :image
  validates :name, presence: true, length: { maximum: 30 }
  validate :due_date_cannot_be_in_the_past
  validate :validate_name_not_including_comma
  belongs_to :user

  scope :recent, -> { order(created_at: :desc) }

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
    %w[name created_at]
  end

  def self.ransackable_association(auth_oabject = nil)
    []
  end
  private

  def validate_name_not_including_comma
    errors.add(:name, "にカンマを含めることはできません") if name&.include?(",")
  end

  def due_date_cannot_be_in_the_past
    errors.add(:due_date, "に過去の日付は指定できません") if due_date&.past?
  end
end
