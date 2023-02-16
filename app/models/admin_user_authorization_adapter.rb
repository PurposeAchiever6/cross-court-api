class AdminUserAuthorizationAdapter < ActiveAdmin::AuthorizationAdapter
  def authorized?(_action, subject = nil)
    if subject.methods.include?(:superclass) && subject.superclass.name == ApplicationRecord.name
      user.can?(Permission.ability_resource_name(Permission::MANAGE, subject.name))
    elsif subject.methods.include?(:class) &&
          subject.class.superclass.name == ApplicationRecord.name
      user.can?(Permission.ability_resource_name(Permission::MANAGE, subject.class.name))
    else
      true
    end
  end
end
