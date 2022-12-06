ActiveAdmin.register PlayerEvaluationFormSection do
  menu label: 'Player Evaluation Form', parent: 'Player Evaluation', priority: 1

  permit_params :title,
                :subtitle,
                :order,
                :required,
                options_attributes: %i[id title content score _destroy]

  config.sort_order = 'order_asc'

  includes :options

  filter :title

  form do |f|
    f.inputs 'Player Evaluation Form Section Details' do
      f.input :title
      f.input :subtitle
      f.input :order
      f.input :required
    end

    f.inputs 'Options' do
      f.has_many :options, allow_destroy: true do |o|
        o.input :title
        o.input :content
        o.input :score
      end
    end

    actions
  end

  index do
    selectable_column
    id_column
    column :title
    column :subtitle
    column :order
    column :options do |player_evaluation_form_section|
      simple_format(player_evaluation_form_section.options_formatted)
    end
    column :required

    actions
  end

  show do
    attributes_table do
      row :title
      row :subtitle
      row :order
      row :required
      row :updated_at
      row :created_at
    end

    panel 'Options' do
      table_for player_evaluation_form_section.options do
        column :title
        column :content
        column :score
      end
    end
  end
end
