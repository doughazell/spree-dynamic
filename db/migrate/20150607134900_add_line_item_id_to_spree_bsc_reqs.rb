class AddLineItemIdToSpreeBscReqs < ActiveRecord::Migration
  def change
    # 14/6/15 DH: 'PG::UndefinedTable: ERROR:  relation "line_items" does not exist'
    #add_reference :spree_bsc_reqs, :line_item, index: true, foreign_key: true
    add_reference :spree_bsc_reqs, :spree_line_item, index: true, foreign_key: true
    
    # 14/6/15 DH: Orig migration for when 'spree_line_items' contained the FK
    #add_reference :spree_line_items, :bsc_req, index: true
    
    #add_reference :spree_bsc_reqs, :line_item, index: true
  end
end
