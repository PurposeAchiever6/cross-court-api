require 'rails_helper'

describe UserSessions::LateArrival do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:session) { create(:session, :daily, location:, time: session_time) }
    let!(:user_session) { create(:user_session, user:, session:, date:) }
    let!(:location) do
      create(:location, late_arrival_minutes:, late_arrival_fee:, allowed_late_arrivals:)
    end

    let(:checked_in_time) { ActiveSupport::TimeZone[location.time_zone].parse('12:31:00') }
    let(:session_time) { Time.parse('12:00:00 UTC') }
    let(:date) { Time.current.in_time_zone(location.time_zone).to_date }
    let(:late_arrival_minutes) { 30 }
    let(:late_arrival_fee) { 20 }
    let(:allowed_late_arrivals) { 2 }

    before { allow(SendSonar).to receive(:message_customer) }

    subject { UserSessions::LateArrival.call(user_session:, checked_in_time:) }

    it { expect { subject }.to change(LateArrival, :count).by(1) }

    it 'calls Sonar service' do
      expect(SonarService).to receive(:send_message).with(
        user,
        "Hey #{user.first_name}. You were checked into Crosscourt beyond 30 minutes after " \
        'session start time. This is considered a late arrival. We know things happen so we ' \
        'allow 2 unpenalized late arrivals. After your 3rd late arrival, you will be charged ' \
        "a $20 late arrival fee for each occurrence thereafter. Thanks.\n"
      )

      subject
    end

    context 'when user has reached the permitted allow late arrivals' do
      let!(:late_arrivals) { create_list(:late_arrival, 2, user:) }
      let!(:user_payment_method) { create(:payment_method, user:, default: true) }

      before { allow(StripeService).to receive(:charge).and_return(double(id: rand(1_000))) }

      it { expect { subject }.to change(LateArrival, :count).by(1) }

      it { expect { subject }.to change { Payment.count }.by(1) }

      it 'calls Stripe service' do
        expect(StripeService).to receive(:charge).with(
          user,
          user_payment_method.stripe_id,
          late_arrival_fee,
          'Session late arrival fee'
        )

        subject
      end

      it 'does not call Sonar service' do
        expect(SonarService).not_to receive(:send_message)
        subject
      end
    end

    context 'when the check in is not considered as late arrival' do
      let(:late_arrival_minutes) { 31 }

      it { expect { subject }.not_to change(LateArrival, :count) }

      it 'does not call Stripe service' do
        expect(StripeService).not_to receive(:charge)
        subject
      end

      it 'does not call Sonar service' do
        expect(SonarService).not_to receive(:send_message)
        subject
      end
    end

    context 'when the late arrival fee is not positive' do
      let(:late_arrival_fee) { 0 }

      it { expect { subject }.not_to change(LateArrival, :count) }

      it 'does not call Stripe service' do
        expect(StripeService).not_to receive(:charge)
        subject
      end

      it 'does not call Sonar service' do
        expect(SonarService).not_to receive(:send_message)
        subject
      end
    end

    context 'when the user session already has a late arrival association' do
      let!(:late_arrival) { create(:late_arrival, user_session:, user:) }

      it { expect { subject }.not_to change(LateArrival, :count) }

      it 'does not call Stripe service' do
        expect(StripeService).not_to receive(:charge)
        subject
      end

      it 'does not call Sonar service' do
        expect(SonarService).not_to receive(:send_message)
        subject
      end
    end
  end
end
