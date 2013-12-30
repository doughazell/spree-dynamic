class AddBscSpecToLineItems < ActiveRecord::Migration
  def change
    add_column :spree_line_items, :bsc_spec, :string
  end
end
