class Attachment < ApplicationRecord
  belongs_to :message
  has_one_attached :file

  validates :file_name, presence: true
  validates :content_type, presence: true
  validates :file_size, presence: true, numericality: { greater_than: 0 }

  # File size limit: 10MB
  MAX_FILE_SIZE = 10.megabytes

  validate :acceptable_file_size

  def image?
    content_type.start_with?("image/")
  end

  def video?
    content_type.start_with?("video/")
  end

  def document?
    !image? && !video?
  end

  private

  def acceptable_file_size
    return unless file.attached?

    if file.byte_size > MAX_FILE_SIZE
      errors.add(:file, "is too large (maximum is #{MAX_FILE_SIZE / 1.megabyte}MB)")
    end
  end
end
