ActiveAdmin.register GalleryPhoto do
  permit_params :image

  form do |f|
    f.inputs 'Image' do
      f.input :image, as: :file
    end

    f.actions
  end

  index do
    selectable_column
    column :image do |gallery_photo|
      image_tag url_for(gallery_photo.image), class: 'max-h-100' if gallery_photo.image.attached?
    end
    column :created_at

    actions
  end

  show do
    attributes_table do
      row :id
      row :image do |gallery_photo|
        image_tag url_for(gallery_photo.image), class: 'max-h-100' if gallery_photo.image.attached?
      end
      row :created_at
    end
  end
end
