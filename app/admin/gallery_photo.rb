ActiveAdmin.register GalleryPhoto do
  menu label: 'Gallery', priority: 4

  actions :all, except: :edit

  before_action :skip_sidebar!, only: :index

  permit_params :image

  form do |f|
    f.inputs 'Images' do
      f.input :image,
              label: 'Images',
              as: :file,
              input_html: {
                include_hidden: false,
                multipart: true,
                multiple: true,
                accept: 'image/*'
              }
    end

    f.actions do
      f.action :submit, as: :button, label: 'Add Gallery Photos'
      f.action :cancel, wrapper_html: { class: 'cancel' }, label: 'Cancel'
    end
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

  controller do
    def create
      gallery_photo_params = params[:gallery_photo]

      if gallery_photo_params.blank?
        @resource = GalleryPhoto.new

        flash.now[:error] = 'You need to select at least one photo to upload'

        render :new
      else
        gallery_photo_params[:image].each do |image|
          GalleryPhoto.create!(image:)
        end

        redirect_to admin_gallery_photos_path
      end
    end
  end
end
