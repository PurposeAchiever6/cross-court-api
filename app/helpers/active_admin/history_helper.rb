module ActiveAdmin
  module HistoryHelper
    EXCLUDED_CHANGES_COLUMNS = %w[created_at updated_at].freeze

    def version_user(version)
      version_whodunnit = version.whodunnit

      return 'public user OR from console' unless version_whodunnit

      type, user_id = version_whodunnit.split('-')
      type == 'admin' ? AdminUser.find(user_id).email : User.find(user_id).email
    end

    def changes_table(version, abre_context)
      changes = version.object_changes.to_a.sort

      abre_context.attributes_table_for version do
        changes.each do |attribute, values|
          next if EXCLUDED_CHANGES_COLUMNS.include?(attribute)

          old_value, new_value = values

          abre_context.row(attribute) do
            abre_context.span old_value.presence || 'empty',
                              class: ('font-bold italic' if old_value.blank?).to_s
            abre_context.text_node fa_icon('arrow-right', class: 'fa-lg mx-3')
            abre_context.span new_value.presence || 'empty',
                              class: ('font-bold italic' if new_value.blank?).to_s
          end
        end
      end
    end
  end
end
