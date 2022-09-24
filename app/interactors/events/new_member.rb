module Events
  class NewMember
    include Interactor

    def call
      user = context.user

      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::NEW_MEMBER,
        user.id,
        subscription_name: context.product.name
      )

      SonarService.send_message(
        user,
        I18n.t(
          'notifier.sonar.new_member_welcome',
          name: user.first_name,
          link: 'https://calendly.com/brendancrosscourt/welcome-to-the-ccteam-5-min-call'
        )
      )
    end
  end
end
