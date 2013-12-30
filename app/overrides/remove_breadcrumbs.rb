Deface::Override.new(:virtual_path => 'spree/layouts/spree_application',
                     :name => 'my_remote_cart_form',
                     :remove => "code[erb-loud]:contains('breadcrumbs(@taxon)')")
