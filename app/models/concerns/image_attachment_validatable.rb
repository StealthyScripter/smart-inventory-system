module ImageAttachmentValidatable
  extend ActiveSupport::Concern

  MAX_IMAGE_SIZE = 5.megabytes

  class_methods do
    def validates_image_attachments(*attachment_names)
      validate do
        attachment_names.each { |attachment_name| validate_image_attachment(attachment_name) }
      end
    end
  end

  private

  def validate_image_attachment(attachment_name)
    attachment = public_send(attachment_name)
    return unless attachment.attached?

    attachment_blobs(attachment).each do |blob|
      errors.add(attachment_name, "must be an image") unless blob.content_type.to_s.start_with?("image/")
      errors.add(attachment_name, "must be 5MB or smaller") if blob.byte_size > MAX_IMAGE_SIZE
    end
  end

  def attachment_blobs(attachment)
    return attachment.blobs if attachment.respond_to?(:blobs)
    return [attachment.blob].compact if attachment.respond_to?(:blob)

    []
  end
end
