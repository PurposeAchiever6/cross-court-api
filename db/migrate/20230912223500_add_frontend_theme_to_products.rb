class AddFrontendThemeToProducts < ActiveRecord::Migration[7.0]
  def up
    add_column :products, :frontend_theme, :integer, default: 0

    Product.where(trial: true).update_all(frontend_theme: :white)
    Product.where(highlighted: true).update_all(frontend_theme: :highlighted)

    remove_column :products, :highlighted
  end

  def down
    add_column :products, :highlighted, :boolean, default: false

    Product.highlighted_frontend_theme.update_all(highlighted: true)

    remove_column :products, :frontend_theme
  end
end
