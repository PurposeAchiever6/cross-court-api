require 'rails_helper'

describe 'PUT /api/v1/user/update_personal_info' do
  let!(:user) { create(:user) }
  let!(:personal_info) do
    {
      weight: '35',
      height: '311',
      competitive_basketball_activity: 'Varsity',
      current_basketball_activity: 'Equinox',
      position: 'point_guard',
      goals: ['Play better', 'Enjoy'],
      main_goal: 'Play better'
    }
  end

  let(:params) { { email: user.email, personal_info: personal_info } }

  subject do
    put update_personal_info_api_v1_user_path,
        headers: nil,
        params: params,
        as: :json
    response
  end

  it { is_expected.to be_successful }
  it { expect(subject.body).to be_empty }

  it { expect { subject }.to change { user.reload.weight }.from(nil).to(35) }
  it { expect { subject }.to change { user.reload.height }.from(nil).to(311) }
  it do
    expect { subject }.to change {
      user.reload.competitive_basketball_activity
    }.from(nil).to('Varsity')
  end
  it do
    expect { subject }.to change {
      user.reload.current_basketball_activity
    }.from(nil).to('Equinox')
  end
  it { expect { subject }.to change { user.reload.position }.from(nil).to('point_guard') }
  it { expect { subject }.to change { user.reload.goals }.from(nil).to(['Play better', 'Enjoy']) }
  it { expect { subject }.to change { user.reload.main_goal }.from(nil).to('Play better') }

  context 'when the user does not exist' do
    before { params[:email] = 'not-exist' }

    it { is_expected.to have_http_status(:not_found) }
  end
end
