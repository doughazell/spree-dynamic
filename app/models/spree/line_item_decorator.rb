Spree::LineItem.class_eval do
  belongs_to :bsc_req, class_name: "Spree::BscReq"
end