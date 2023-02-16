module Seeds
  module RolesAndPermissions
    def self.run
      Permission::ABILITIES.each do |ability|
        ApplicationRecord.send(:subclasses).map(&:name).each do |resource|
          Permission.find_or_create_by(name: "#{ability}::#{resource}")
        end
      end

      super_admin_role_id = Role.find_or_create_by(name: 'Super Admin').id
      Role.find_or_create_by(name: 'Staff')

      super_admin = AdminUser.find_by(email: 'admin@example.com')

      if super_admin
        AdminUserRole.find_or_create_by(role_id: super_admin_role_id, admin_user_id: super_admin.id)
      end

      Permission.all.each do |permission|
        RolePermission.find_or_create_by(role_id: super_admin_role_id, permission_id: permission.id)
      end
    end
  end
end
