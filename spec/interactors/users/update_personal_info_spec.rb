require 'rails_helper'

describe Users::UpdatePersonalInfo do
  describe '.call' do
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

    subject { Users::UpdatePersonalInfo.call(user:, personal_info:) }

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
  end
end