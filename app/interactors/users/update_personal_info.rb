module Users
  class UpdatePersonalInfo
    include Interactor

    def call
      user = context.user
      personal_info = context.personal_info

      user.update!(personal_info)
    end
  end
end
