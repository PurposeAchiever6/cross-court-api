require 'rails_helper'

describe UserSessions::Create do
  describe '.call' do
    let!(:location) do
      create(
        :location,
        max_sessions_booked_per_day:,
        max_skill_sessions_booked_per_day:
      )
    end
    let!(:session) do
      create(
        :session,
        :daily,
        location:,
        time: session_time,
        is_open_club:,
        skill_session:,
        max_first_timers:,
        all_skill_levels_allowed:,
        members_only:,
        cost_credits:,
        allow_back_to_back_reservations:
      )
    end
    let!(:user) do
      create(
        :user,
        credits:,
        credits_without_expiration:,
        subscription_credits:,
        subscription_skill_session_credits:,
        free_session_state:,
        reserve_team:,
        active_subscription:,
        first_time_subscription_credits_used_at:
      )
    end
    let!(:product) { create(:product, product_type: :recurring) }
    let!(:active_subscription) do
      create(:subscription, product: active_subscription_product, status: subscription_status)
    end

    let(:active_subscription_product) { product }
    let(:max_sessions_booked_per_day) { nil }
    let(:max_skill_sessions_booked_per_day) { nil }
    let(:subscription_status) { :active }
    let(:first_time_subscription_credits_used_at) { Time.zone.today }
    let(:reserve_team) { false }
    let(:skill_session) { false }
    let(:max_first_timers) { nil }
    let(:all_skill_levels_allowed) { true }
    let(:allow_back_to_back_reservations) { true }
    let(:members_only) { false }
    let(:is_open_club) { false }
    let(:cost_credits) { 1 }
    let(:credits) { 1 }
    let(:credits_without_expiration) { 0 }
    let(:subscription_credits) { 0 }
    let(:subscription_skill_session_credits) { 2 }
    let(:free_session_state) { :used }
    let(:time_now) { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
    let(:session_time) { time_now + Session::CANCELLATION_PERIOD + 1.minute }
    let(:date) { time_now.to_date }

    let(:subject_args) { { user:, session:, date: } }
    let(:created_user_session) { UserSession.last }

    before { allow_any_instance_of(Slack::Notifier).to receive(:ping) }

    subject do
      UserSessions::Create.call(subject_args)
    end

    it { expect { subject }.to change(UserSession, :count).by(1) }
    it { expect { subject }.to change { user.reload.credits }.by(-1) }
    it { expect { subject }.not_to change { user.reload.free_session_state } }
    it { expect(subject.user_session.credit_used_type).to eq('credits') }

    it { expect(subject.user_session.id).to eq(created_user_session.id) }
    it { expect(subject.user_session.first_session).to eq(true) }
    it { expect(subject.user_session.is_free_session).to eq(false) }
    it { expect(subject.user_session.state).to eq('reserved') }

    it 'calls Slack service' do
      expect_any_instance_of(SlackService).to receive(:session_booked)
      subject
    end

    it 'enques ActiveCampaign::CreateDealJob' do
      expect { subject }.to have_enqueued_job(
        ::ActiveCampaign::CreateDealJob
      ).with(
        ::ActiveCampaign::Deal::Event::SESSION_BOOKED,
        user.id,
        user_session_id: anything
      )
    end

    it 'sends session booked email' do
      expect { subject }.to have_enqueued_job(
        ActionMailer::MailDeliveryJob
      ).with('SessionMailer', 'session_booked', anything, anything)
    end

    context 'when the session costs 0 credits' do
      let(:cost_credits) { 0 }
      let(:credits) { 0 }

      it { expect { subject }.to change(UserSession, :count).by(1) }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect(subject.user_session.credit_used_type).to eq('credits') }
    end

    context 'when the session costs 2 credits' do
      let(:cost_credits) { 2 }

      it { expect { subject rescue nil }.not_to change(UserSession, :count) }

      it 'raises NotEnoughCreditsException' do
        expect { subject }.to raise_error(
          NotEnoughCreditsException,
          'Not enough credits. Please buy more.'
        )
      end

      context 'when user has enough credits for the session' do
        let(:credits) { 2 }

        it { expect { subject }.to change(UserSession, :count).by(1) }
        it { expect { subject }.to change { user.reload.credits }.by(-2) }
        it { expect(subject.user_session.credit_used_type).to eq('credits') }
      end
    end

    context 'when user does not have credits but has season pass credits' do
      let(:credits) { 0 }
      let(:credits_without_expiration) { 1 }

      it { expect { subject }.to change(UserSession, :count).by(1) }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.to change { user.reload.credits_without_expiration }.by(-1) }
      it { expect { subject }.not_to change { user.reload.subscription_credits } }
      it { expect(subject.user_session.credit_used_type).to eq('credits_without_expiration') }
    end

    context 'when user does not have credits but has subscription_credits' do
      let(:credits) { 0 }
      let(:subscription_credits) { 1 }

      it { expect { subject }.to change(UserSession, :count).by(1) }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.not_to change { user.reload.credits_without_expiration } }
      it { expect { subject }.to change { user.reload.subscription_credits }.by(-1) }
      it { expect(subject.user_session.credit_used_type).to eq('subscription_credits') }

      context 'when user has unlimited subscription' do
        let(:subscription_credits) { Product::UNLIMITED }

        it { expect { subject }.to change(UserSession, :count).by(1) }
        it { expect { subject }.not_to change { user.reload.credits } }
        it { expect { subject }.not_to change { user.reload.credits_without_expiration } }
        it { expect { subject }.not_to change { user.reload.subscription_credits } }
      end
    end

    context 'when there is only one spot left' do
      let!(:user_sessions) do
        create_list(
          :user_session,
          session.max_capacity - 1,
          session:,
          date:
        )
      end

      it { expect { subject }.to change(UserSession, :count).by(1) }

      context 'when session is full' do
        let!(:last_user_session) { create(:user_session, session:, date:) }

        it { expect { subject rescue nil }.not_to change(UserSession, :count) }
        it { expect { subject }.to raise_error(FullSessionException, 'Session is full') }
      end
    end

    context 'when there are no more spots for first timers' do
      let!(:some_user) { create(:user) }
      let!(:user_session) { create(:user_session, session:, date:, user: some_user) }
      let(:max_first_timers) { 1 }

      it { expect { subject rescue nil }.not_to change(UserSession, :count) }
      it { expect { subject }.to raise_error(FullSessionException, 'Session is full') }
    end

    context 'when session is open club' do
      let(:is_open_club) { true }

      it { expect { subject }.to change(UserSession, :count).by(1) }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.not_to change { user.reload.subscription_credits } }
      it { expect { subject }.not_to change { user.reload.subscription_skill_session_credits } }

      context 'when user reserves a shooting machine' do
        let!(:payment_method) { create(:payment_method, user:, default: true) }
        let!(:shooting_machine) { create(:shooting_machine, session:) }

        before do
          subject_args.merge!(shooting_machines: [shooting_machine])
          allow(StripeService).to receive(:charge).and_return(double(id: 'payment_intent'))
        end

        it { expect { subject }.to change(ShootingMachineReservation, :count).by(1) }

        context 'when the shooting machine has already been reserved' do
          let!(:user_session) { create(:user_session, session:, date:) }
          let!(:shooting_machine_reservation) do
            create(
              :shooting_machine_reservation,
              shooting_machine:,
              user_session:
            )
          end

          it { expect { subject }.to raise_error(ShootingMachineAlreadyReservedException) }
          it { expect { subject rescue nil }.not_to change(ShootingMachineReservation, :count) }
        end
      end
    end

    context 'when the session is not for all skill levels' do
      let(:all_skill_levels_allowed) { false }

      before do
        session.skill_level.update!(min: 5, max: 7)
        user.update!(skill_rating: 3)
      end

      it { expect { subject rescue nil }.not_to change(UserSession, :count) }
      it { expect { subject }.to raise_error(SessionIsOutOfSkillLevelException) }

      context 'when the user is advanced' do
        before { user.update(skill_rating: 5) }

        it { expect { subject }.to change(UserSession, :count).by(1) }
      end
    end

    context 'when user has reached the number of sessions booked per day' do
      let(:max_sessions_booked_per_day) { 1 }
      let(:another_session_skill_session) { false }
      let(:user_session_state) { :reserved }
      let(:user_session_date) { date }

      let!(:another_session) do
        create(:session, :daily, location:, skill_session: another_session_skill_session)
      end
      let!(:user_session) do
        create(
          :user_session,
          session: another_session,
          user:,
          date: user_session_date,
          state: user_session_state
        )
      end

      it { expect { subject rescue nil }.not_to change(UserSession, :count) }

      it { expect { subject }.to raise_error(UserBookedSessionsLimitPerDayException) }

      context 'when the user session has been canceled' do
        let(:user_session_state) { :canceled }

        it { expect { subject }.to change(UserSession, :count).by(1) }
      end

      context 'when the user session if not on the same day' do
        let(:user_session_date) { date + 1.day }

        it { expect { subject }.to change(UserSession, :count).by(1) }
      end

      context 'when from_waitlist is true' do
        before do
          subject_args.merge!(from_waitlist: true)
          allow(SonarService).to receive(:send_message)
        end

        it { expect { subject }.to change(UserSession, :count).by(1) }
      end

      context 'when the user session booked is for a skill session' do
        let(:another_session_skill_session) { true }

        it { expect { subject }.to change(UserSession, :count).by(1) }
      end
    end

    context 'when invalid date' do
      let(:date) { time_now.to_date - 1.day }

      it { expect { subject rescue nil }.not_to change(UserSession, :count) }
      it { expect { subject }.to raise_error(InvalidDateException, 'Invalid date') }
    end

    context 'when there is no session for the selected date' do
      let!(:session_exception) { create(:session_exception, session:, date:) }

      it { expect { subject rescue nil }.not_to change(UserSession, :count) }
      it { expect { subject }.to raise_error(InvalidDateException, 'Invalid date') }
    end

    context 'when user does not have any credit' do
      let(:credits) { 0 }

      it { expect { subject rescue nil }.not_to change(UserSession, :count) }

      it 'raises NotEnoughCreditsException' do
        expect { subject }.to raise_error(
          NotEnoughCreditsException,
          'Not enough credits. Please buy more.'
        )
      end
    end

    context 'when not_charge_user_credit is true' do
      before { subject_args.merge!(not_charge_user_credit: true) }

      it { expect { subject }.to change(UserSession, :count).by(1) }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.not_to change { user.reload.subscription_credits } }

      context 'when user does not have any credit' do
        let(:credits) { 0 }

        it { expect { subject }.to change(UserSession, :count).by(1) }
        it { expect { subject }.not_to change { user.reload.credits } }
        it { expect { subject }.not_to change { user.reload.subscription_credits } }
      end
    end

    context 'when user free_session_state is claimed' do
      let(:free_session_state) { :claimed }

      it { expect { subject }.to change(UserSession, :count).by(1) }
      it { expect { subject }.to change { user.reload.free_session_state }.to('used') }
      it { expect(subject.user_session.first_session).to eq(true) }
      it { expect(subject.user_session.is_free_session).to eq(true) }
    end

    context 'when is not user first session' do
      let!(:user_session) { create(:user_session, user:, first_session: true) }

      it { expect(subject.user_session.first_session).to eq(false) }
      it { expect(subject.user_session.is_free_session).to eq(false) }
      it { expect(subject.user_session.state).to eq('reserved') }
    end

    context 'when reservation is inside window cancellation' do
      let(:session_time) { time_now + Session::CANCELLATION_PERIOD - 1.minute }

      before { allow(SonarService).to receive(:send_message) }

      it { expect { subject }.to change(UserSession, :count).by(1) }
      it { expect(subject.user_session.state).to eq('confirmed') }

      it 'calls Sonar service' do
        expect(SonarService).to receive(:send_message)
        subject
      end

      it 'enques ActiveCampaign::CreateDealJob' do
        expect { subject }.to have_enqueued_job(
          ::ActiveCampaign::CreateDealJob
        ).with(
          ::ActiveCampaign::Deal::Event::SESSION_CONFIRMATION,
          user.id,
          user_session_id: anything
        )
      end
    end

    context 'when reservation has a referral' do
      let!(:referral_user) { create(:user) }

      before { subject_args.merge!(referral_code: referral_user.referral_code) }

      it { expect { subject }.to change(UserSession, :count).by(1) }
      it { expect { subject }.to change { referral_user.reload.credits }.by(1) }

      it 'enques ActiveCampaign::CreateDealJob' do
        expect { subject }.to have_enqueued_job(
          ::ActiveCampaign::CreateDealJob
        ).with(
          ::ActiveCampaign::Deal::Event::REFERRAL_SUCCESS,
          referral_user.id,
          referred_id: user.id
        )
      end

      context 'if referral is the same user that reserves' do
        before { subject_args.merge!(referral_code: user.referral_code) }

        it { expect { subject }.to change(UserSession, :count).by(1) }
        it { expect { subject }.not_to change { referral_user.reload.credits } }

        it 'should not enque ActiveCampaign::CreateDealJob' do
          expect { subject }.not_to have_enqueued_job(
            ::ActiveCampaign::CreateDealJob
          ).with(
            ::ActiveCampaign::Deal::Event::REFERRAL_SUCCESS,
            referral_user.id,
            referred_id: user.id
          )
        end
      end

      context 'when is not user first session' do
        let!(:user_session) { create(:user_session, user:) }

        it { expect { subject }.to change(UserSession, :count).by(1) }
        it { expect { subject }.not_to change { referral_user.reload.credits } }

        it 'should not enque ActiveCampaign::CreateDealJob' do
          expect { subject }.not_to have_enqueued_job(
            ::ActiveCampaign::CreateDealJob
          ).with(
            ::ActiveCampaign::Deal::Event::REFERRAL_SUCCESS,
            referral_user.id,
            referred_id: user.id
          )
        end
      end
    end

    context 'when from_waitlist is true' do
      before do
        subject_args.merge!(from_waitlist: true)
        allow(SonarService).to receive(:send_message)
      end

      it { expect { subject }.to change(UserSession, :count).by(1) }
      it { expect(subject.user_session.state).to eq('confirmed') }

      it 'calls Sonar service' do
        expect(SonarService).to receive(:send_message)
        subject
      end

      it 'enques ActiveCampaign::CreateDealJob' do
        expect { subject }.to have_enqueued_job(
          ::ActiveCampaign::CreateDealJob
        ).with(
          ::ActiveCampaign::Deal::Event::SESSION_CONFIRMATION,
          user.id,
          user_session_id: anything
        )
      end

      it 'calls Slack service for session_waitlist_confirmed' do
        expect_any_instance_of(SlackService).to receive(:session_waitlist_confirmed)
        subject
      end

      it 'does not call Slack service for session_booked' do
        expect_any_instance_of(SlackService).not_to receive(:session_booked)
        subject
      end

      context 'when reservation is inside window cancellation' do
        let(:session_time) { time_now + Session::CANCELLATION_PERIOD - 1.minute }

        it { expect { subject }.to change(UserSession, :count).by(1) }
        it { expect(subject.user_session.state).to eq('confirmed') }

        it 'calls Slack service for session_waitlist_confirmed' do
          expect_any_instance_of(SlackService).to receive(:session_waitlist_confirmed)
          subject
        end
      end
    end

    context 'when user has a paused subscription' do
      let(:subscription_status) { :paused }

      it { expect { subject rescue nil }.not_to change(UserSession, :count) }
      it do
        expect {
          subject
        }.to raise_error(SubscriptionIsNotActiveException, 'The subscription is not active')
      end
    end

    context 'when the user is from the reserve team' do
      before { ENV['RESERVE_TEAM_RESERVATIONS_LIMIT'] = '1' }

      let(:reserve_team) { true }

      it { expect { subject }.to change(UserSession, :count).by(1) }

      context 'when the session is not allowed for reserve team members' do
        let!(:user_session) { create(:user_session, session:, date:) }

        it { expect { subject rescue nil }.not_to change(UserSession, :count) }
      end
    end

    context 'when the user consumed all the subscription credits' do
      let(:subscription_credits) { 1 }
      let(:credits) { 0 }

      let(:message) do
        I18n.t(
          'notifier.sonar.first_time_subscription_credits_used',
          name: user.first_name,
          link: "#{ENV.fetch('FRONTENT_URL', nil)}/memberships"
        )
      end

      before { allow(SonarService).to receive(:send_message) }

      context 'when is the first time' do
        let(:first_time_subscription_credits_used_at) { nil }

        it 'calls Sonar service' do
          expect(SonarService).to receive(:send_message).with(user, message).once
          subject
        end
      end

      context 'when is not the first time' do
        let(:first_time_subscription_credits_used_at) { Time.zone.yesterday }

        it 'does not calls Sonar service' do
          expect(SonarService).not_to receive(:send_message)
          subject
        end
      end
    end

    context 'when is a skill session' do
      let(:skill_session) { true }
      let(:credits) { 1 }
      let(:subscription_credits) { 1 }
      let(:subscription_skill_session_credits) { 1 }

      it { expect { subject }.to change(UserSession, :count).by(1) }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.not_to change { user.reload.subscription_credits } }
      it { expect { subject }.to change { user.reload.subscription_skill_session_credits }.by(-1) }

      it 'sets the correct user session credit_used_type' do
        expect(subject.user_session.credit_used_type).to eq('subscription_skill_session_credits')
      end

      context 'when the session costs 2 credits' do
        let(:cost_credits) { 2 }

        it { expect { subject rescue nil }.not_to change(UserSession, :count) }

        it 'raises NotEnoughCreditsException' do
          expect { subject }.to raise_error(
            NotEnoughCreditsException,
            'Not enough credits. Please buy more.'
          )
        end

        context 'when user has enough credits for the session' do
          let(:subscription_skill_session_credits) { 2 }

          it { expect { subject }.to change(UserSession, :count).by(1) }
          it { expect { subject }.not_to change { user.reload.credits } }
          it { expect { subject }.not_to change { user.reload.subscription_credits } }

          it 'decrements the correct credits to user' do
            expect { subject }.to change { user.reload.subscription_skill_session_credits }.by(-2)
          end

          it 'sets the correct user session credit_used_type' do
            expect(
              subject.user_session.credit_used_type
            ).to eq('subscription_skill_session_credits')
          end
        end
      end

      context 'when user has unlimited skill session credits' do
        let(:subscription_skill_session_credits) { Product::UNLIMITED }

        it { expect { subject }.to change(UserSession, :count).by(1) }
        it { expect { subject }.not_to change { user.reload.credits } }
        it { expect { subject }.not_to change { user.reload.subscription_credits } }
        it { expect { subject }.not_to change { user.reload.subscription_skill_session_credits } }
      end

      context 'when user does not have any subscription skill session credit' do
        let(:subscription_skill_session_credits) { 0 }

        it { expect { subject }.to change(UserSession, :count).by(1) }
        it { expect { subject }.to change { user.reload.credits }.by(-1) }
        it { expect { subject }.not_to change { user.reload.subscription_credits } }
        it { expect { subject }.not_to change { user.reload.subscription_skill_session_credits } }
        it { expect(subject.user_session.credit_used_type).to eq('credits') }

        context 'when user does not have credit' do
          let(:credits) { 0 }

          it { expect { subject }.to change(UserSession, :count).by(1) }
          it { expect { subject }.not_to change { user.reload.credits } }
          it { expect { subject }.to change { user.reload.subscription_credits }.by(-1) }
          it { expect { subject }.not_to change { user.reload.subscription_skill_session_credits } }
          it { expect(subject.user_session.credit_used_type).to eq('subscription_credits') }

          context 'when user does not have any subscription credit' do
            let(:subscription_credits) { 0 }

            it { expect { subject rescue nil }.not_to change(UserSession, :count) }

            it 'raises NotEnoughCreditsException' do
              expect { subject }.to raise_error(
                NotEnoughCreditsException,
                'Not enough credits. Please buy more.'
              )
            end

            it { expect { subject rescue nil }.not_to change { user.reload.credits } }
            it { expect { subject rescue nil }.not_to change { user.reload.subscription_credits } }

            it 'does not update user subscription_skill_session_credits' do
              expect {
                subject rescue nil
              }.not_to change { user.reload.subscription_skill_session_credits }
            end
          end
        end
      end

      context 'when user has reached the number of skill sessions booked' do
        let(:max_skill_sessions_booked_per_day) { 1 }
        let(:another_session_skill_session) { true }
        let(:user_session_state) { :reserved }
        let(:user_session_date) { date }

        let!(:another_session) do
          create(:session, :daily, location:, skill_session: another_session_skill_session)
        end
        let!(:user_session) do
          create(
            :user_session,
            session: another_session,
            user:,
            date: user_session_date,
            state: user_session_state
          )
        end

        it { expect { subject rescue nil }.not_to change(UserSession, :count) }

        it { expect { subject }.to raise_error(UserBookedSessionsLimitPerDayException) }

        context 'when the user session has been canceled' do
          let(:user_session_state) { :canceled }

          it { expect { subject }.to change(UserSession, :count).by(1) }
        end

        context 'when the user session if not on the same day' do
          let(:user_session_date) { date + 1.day }

          it { expect { subject }.to change(UserSession, :count).by(1) }
        end

        context 'when from_waitlist is true' do
          before do
            subject_args.merge!(from_waitlist: true)
            allow(SonarService).to receive(:send_message)
          end

          it { expect { subject }.to change(UserSession, :count).by(1) }
        end

        context 'when the user session booked is a normal session' do
          let(:another_session_skill_session) { false }

          it { expect { subject }.to change(UserSession, :count).by(1) }
        end
      end
    end

    context 'when session is only for members' do
      let(:members_only) { true }

      it { expect { subject }.to change(UserSession, :count).by(1) }

      context 'when user does not have an active subscription' do
        let(:active_subscription) { nil }

        it { expect { subject rescue nil }.not_to change(UserSession, :count) }

        it 'raises SessionAllowedMembersException' do
          expect { subject }.to raise_error(
            SessionAllowedMembersException,
            'The session is only for members or is restricted for certain memberships'
          )
        end
      end

      context 'when the session is only allowed for certain product' do
        let!(:session_allowed_product) do
          create(:session_allowed_product, session:, product:)
        end

        it { expect { subject }.to change(UserSession, :count).by(1) }

        context 'when user active subscription product is not allowed' do
          let!(:another_product) { create(:product, product_type: :recurring) }
          let(:active_subscription_product) { another_product }

          it { expect { subject rescue nil }.not_to change(UserSession, :count) }

          it 'raises SessionAllowedMembersException' do
            expect { subject }.to raise_error(
              SessionAllowedMembersException,
              'The session is only for members or is restricted for certain memberships'
            )
          end
        end
      end
    end

    context 'when session does not allow back to back sessions' do
      let(:allow_back_to_back_reservations) { false }
      let(:before_session_allow_back_to_back_reservations) { false }

      let!(:before_session) do
        create(
          :session,
          :daily,
          location:,
          time: session_time - 1.hour,
          duration_minutes: 55,
          allow_back_to_back_reservations: before_session_allow_back_to_back_reservations
        )
      end
      let!(:user_session) do
        create(
          :user_session,
          session: before_session,
          user:,
          date:
        )
      end

      it { expect { subject rescue nil }.not_to change(UserSession, :count) }

      it 'raises BackToBackSessionReservationException' do
        expect { subject }.to raise_error(
          BackToBackSessionReservationException,
          "This session doesn't allow back to back reservations"
        )
      end

      context 'when session allows back to back reservations' do
        let(:allow_back_to_back_reservations) { true }

        it { expect { subject }.to change(UserSession, :count).by(1) }
      end

      context 'when before session allows back to back reservations' do
        let(:before_session_allow_back_to_back_reservations) { true }

        it { expect { subject }.to change(UserSession, :count).by(1) }
      end

      context 'when the user canceled the before session' do
        before { user_session.update!(state: :canceled) }

        it { expect { subject }.to change(UserSession, :count).by(1) }
      end

      context 'when is inside reservation window for back to back sessions' do
        let!(:session_reservations) do
          create_list(:user_session, session_reservations_count, session:, date:)
        end

        let(:session_reservations_count) { 9 }
        let(:session_time) { time_now + 2.hours - 1.minute }

        before { allow(SonarService).to receive(:send_message) }

        it { expect { subject }.to change(UserSession, :count).by(1) }

        context 'when session has more reservations than the max allowed for back to back' do
          let(:session_reservations_count) { 10 }

          it { expect { subject rescue nil }.not_to change(UserSession, :count) }

          it 'raises BackToBackSessionReservationException' do
            expect { subject }.to raise_error(
              BackToBackSessionReservationException,
              "This session doesn't allow back to back reservations"
            )
          end
        end
      end
    end
  end
end
