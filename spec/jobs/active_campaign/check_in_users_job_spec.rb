require 'rails_helper'

describe ::ActiveCampaign::CheckInUsersJob do
  describe '#perform' do
    let(:la_time)  { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
    let!(:la_date) { la_time.to_date }
    let!(:session) { create(:session) }

    let(:subscription_credits) { rand(1..5) }
    let(:active_subscription) { create(:subscription) }
    let(:is_free_session) { false }

    let!(:user) do
      create(
        :user,
        subscription_credits: subscription_credits,
        active_subscription: active_subscription
      )
    end

    let!(:user_session) do
      create(
        :user_session,
        user: user,
        session: session,
        checked_in: true,
        date: la_date,
        state: :confirmed,
        is_free_session: is_free_session
      )
    end

    let(:instance) { instance_double(ActiveCampaignService) }
    let(:double_class) { class_double(ActiveCampaignService).as_stubbed_const }

    before do
      allow(double_class).to receive(:new).and_return(instance)
      allow(instance).to receive(:create_deal)
    end

    subject { described_class.perform_now(user_session.id) }

    context 'when time_to_re_up and drop_in_re_up conditions are not met' do
      context 'when is not free session' do
        it do
          expect(instance).to receive(:create_deal).once.with(
            ::ActiveCampaign::Deal::Event::SESSION_CHECK_IN,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::FREE_SESSION_CHECK_IN,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::TIME_TO_RE_UP,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::DROP_IN_RE_UP,
            user
          )

          subject
        end
      end

      context 'when is free session' do
        let(:is_free_session) { true }

        it do
          expect(instance).to receive(:create_deal).once.with(
            ::ActiveCampaign::Deal::Event::FREE_SESSION_CHECK_IN,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::SESSION_CHECK_IN,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::TIME_TO_RE_UP,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::DROP_IN_RE_UP,
            user
          )

          subject
        end
      end
    end

    context 'when calling ActiveCampaign multiple times' do
      context 'when time_to_re_up conditions are met' do
        let(:subscription_credits) { 0 }

        it do
          expect(instance).to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::SESSION_CHECK_IN,
            user
          )
          expect(instance).to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::TIME_TO_RE_UP,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::FREE_SESSION_CHECK_IN,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::DROP_IN_RE_UP,
            user
          )

          subject
        end
      end

      context 'drop_in_re_up are met' do
        let(:active_subscription) { nil }

        it do
          expect(instance).to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::SESSION_CHECK_IN,
            user
          )
          expect(instance).to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::DROP_IN_RE_UP,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::TIME_TO_RE_UP,
            user
          )
          expect(instance).not_to receive(:create_deal).with(
            ::ActiveCampaign::Deal::Event::FREE_SESSION_CHECK_IN,
            user
          )

          subject
        end
      end
    end
  end
end
