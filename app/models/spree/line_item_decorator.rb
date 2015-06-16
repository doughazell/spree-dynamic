Spree::LineItem.class_eval do
  # 7/6/15 DH: Altered FK place of LineItem<->BscReq + Need migration to add FK to BscReq:
  #            $ rails g migration AddLineItemIDToSpreeBscReqs spree_line_item:references
  #belongs_to :bsc_req, class_name: "Spree::BscReq"
  has_one :bsc_req, class_name: "Spree::BscReq", dependent: :destroy
end