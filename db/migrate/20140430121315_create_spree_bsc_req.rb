class CreateSpreeBscReq < ActiveRecord::Migration
  def change
    create_table :spree_bsc_reqs do |t|
      t.integer :width
      t.integer :drop
      t.string :lining
      t.string :heading
    end
  end
end
