class AddNotNullToSpreeBscReq < ActiveRecord::Migration
  def change
    change_column :spree_bsc_reqs, :width, :integer, :null => false
    change_column :spree_bsc_reqs, :drop, :integer, :null => false
    change_column :spree_bsc_reqs, :lining, :string, :null => false
    change_column :spree_bsc_reqs, :heading, :string, :null => false
  end
end
