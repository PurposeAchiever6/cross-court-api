RSpec.shared_context 'disable bullet', shared_context: :metadata do
  before { Bullet.enable = false }
  after { Bullet.enable = true }
end
