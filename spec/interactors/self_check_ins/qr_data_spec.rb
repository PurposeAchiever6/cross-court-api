require 'rails_helper'

describe SelfCheckIns::QrData do
  describe '.call' do
    let(:location_id) { rand(1..10) }
    subject { described_class.call(location_id:) }

    before { Timecop.freeze(Time.current) }

    after { Timecop.return }

    it { expect(subject.data).not_to be_empty }
    it { expect(subject.refresh_time_ms).to eq(SelfCheckIns::QrData::REFRESH_TIME.in_milliseconds) }
  end
end
