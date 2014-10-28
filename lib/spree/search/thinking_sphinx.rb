module Spree::Search
  class ThinkingSphinx < Spree::Core::Search::Base
    def initialize(params)
      super(params)
    end
    
    protected
    # method should return AR::Relations with conditions {:conditions=> "..."} for Product model
    def get_products_conditions_for(base_scope, query)
      search_options = {page: page, per_page: per_page}
      options = {}  #with_opts || 
      if taxon
        taxon_ids = taxon.self_and_descendants.map(&:id)
        options.merge!(:taxon_ids => taxon_ids)
      end

      search_options.merge!(:with => options)

      product_ids = Spree::Product.search_for_ids(query, search_options)
      @properties[:product_ids] = product_ids
      @properties[:facets] = product_ids.facets
      base_scope.where("#{Spree::Product.table_name}.id" => @properties[:product_ids])
    end

    # Copied because we want to use sphinx even if keywords is blank
    # This method is equal to one from spree without unless keywords.blank? in get_products_conditions_for
    def get_base_scope
      base_scope = super
      #base_scope = get_products_conditions_for(base_scope, keywords)
      base_scope
    end
  end
end
