Spree::LineItem.class_eval do
  # 7/6/15 DH: Altered FK place of LineItem<->BscReq + Need migration to add FK to BscReq:
  #            $ rails g migration AddLineItemIDToSpreeBscReqs spree_line_item:references
  #belongs_to :bsc_req, class_name: "Spree::BscReq"
  
  # 11/10/16 DH: http://guides.rubyonrails.org/association_basics.html#has-one-association-reference
  # but 'validate: true' prob won't work due to 
  # 'validates_presence_of :width, :drop, :lining, :heading' in 'Spree::BscReq'
  has_one :bsc_req, class_name: "Spree::BscReq", dependent: :destroy
end