FactoryBot.define do
  factory :employee_session do
    session
    user
    date { Date.tomorrow }
  end

  factory :sem_session, parent: :employee_session, class: SemSession.to_s do
    type { SemSession.to_s }
  end

  factory :referee_session, parent: :employee_session, class: RefereeSession.to_s do
    type { RefereeSession.to_s }
  end
end
