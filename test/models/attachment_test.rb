require "test_helper"

class AttachmentTest < ActiveSupport::TestCase
  test "should belong to message" do
    attachment = attachments(:one)
    assert_not_nil attachment.message
  end

  test "should validate presence of file_name" do
    attachment = Attachment.new(content_type: "image/png", file_size: 1024)
    assert_not attachment.valid?
    assert_includes attachment.errors[:file_name], "can't be blank"
  end

  test "should validate presence of content_type" do
    attachment = Attachment.new(file_name: "test.png", file_size: 1024)
    assert_not attachment.valid?
    assert_includes attachment.errors[:content_type], "can't be blank"
  end

  test "should validate presence of file_size" do
    attachment = Attachment.new(file_name: "test.png", content_type: "image/png")
    assert_not attachment.valid?
    assert_includes attachment.errors[:file_size], "can't be blank"
  end

  test "should identify image types" do
    attachment = Attachment.new(content_type: "image/png", file_name: "test.png", file_size: 1024)
    assert attachment.image?
    assert_not attachment.video?
    assert_not attachment.document?
  end

  test "should identify video types" do
    attachment = Attachment.new(content_type: "video/mp4", file_name: "test.mp4", file_size: 1024)
    assert attachment.video?
    assert_not attachment.image?
    assert_not attachment.document?
  end

  test "should identify document types" do
    attachment = Attachment.new(content_type: "application/pdf", file_name: "test.pdf", file_size: 1024)
    assert attachment.document?
    assert_not attachment.image?
    assert_not attachment.video?
  end
end
