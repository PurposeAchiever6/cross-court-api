require 'rails_helper'

describe 'GET api/v1/gallery_photos' do
  let(:user) { create(:user) }
  let(:gallery_photos_count) { rand(1..10) }
  let!(:gallery_photos) { create_list(:gallery_photo, gallery_photos_count) }

  before { get api_v1_gallery_photos_path, headers: auth_headers, as: :json }

  it 'returns success' do
    expect(response).to have_http_status(:success)
  end

  it { expect(json[:gallery_photos].length).to eq(gallery_photos_count) }

  describe 'the gallery photo' do
    subject { json[:gallery_photos].first }

    it { expect(subject[:id]).to eq(gallery_photos.last.id) }
    it { expect(subject[:image_url]).to eq(polymorphic_url(gallery_photos.last.image)) }
  end
end
