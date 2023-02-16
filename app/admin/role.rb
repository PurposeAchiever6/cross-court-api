ActiveAdmin.register Role do
  menu parent: 'Roles and Permissions', priority: 1
  permit_params :name
end
