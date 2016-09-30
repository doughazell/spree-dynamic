Deface::Override.new(:virtual_path => 'spree/layouts/spree_application',
                     :name => 'remove_breadcrumbs',
                     :remove => "erb[loud]:contains('breadcrumbs(@taxon)')")
