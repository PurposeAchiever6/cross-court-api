class AddAttachment
  include Interactor

  def call
    object = context.object
    column_name = context.column_name
    base_64_attachment = context.base_64_attachment
    attachment_name = context.attachment_name

    content_type = base_64_attachment.split(',').first.split(':').last.split(';').first
    decoded_image = Base64.decode64(base_64_attachment.split(',').last)

    object.send(column_name).attach(
      io: StringIO.new(decoded_image),
      content_type: content_type,
      filename: "#{attachment_name}.#{content_type.split('/').last}"
    )
  end
end
