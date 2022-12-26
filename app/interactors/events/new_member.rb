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
          link: 'https://calendly.com/rpadilla-55/new-member-kick-off-call'
        )
      )
    end
  end
end
