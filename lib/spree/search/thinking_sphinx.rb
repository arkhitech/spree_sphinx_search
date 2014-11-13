module Spree::Search
  class ThinkingSphinx < Spree::Core::Search::Base
    def initialize(params)
      super(params)
    end
    
    protected
    # method should return AR::Relations with conditions {:conditions=> "..."} for Product model
    def get_products_conditions_for(base_scope, query)
      search_options = {page: page, per_page: per_page}
      options = {}     
      cond_options = {}
      if search
        if search[:price_range_any].present?
          case search[:price_range_any]
          when /under.*10/i
            unless Spree::Config.show_products_without_price
              options.merge!(price: 0.0..10.0)
            else
              options.merge!(price: 0..10.0)
            end          
          when /10.*15/i
            options.merge!(price: 10..15.0)
          when /15.*18/i
            options.merge!(price: 15..18.0)
          when /18.*20/i
            options.merge!(price: 18..20.0)
          when /20.*over/i
            options.merge!(price: 20..500000.0)
          else
            unless Spree::Config.show_products_without_price
              options.merge!(price: 0.00..500000.0)
            end          
          end
        end
        if search[:brand_any].present?
          cond_options.merge!(taxon_name: search[:brand_any])
        end        
        if search[:taxons].present?
          options.merge!(filter_taxon_ids: search[:taxons])
        end
      end
      
      if taxon
        taxon_ids = taxon.self_and_descendants.map(&:id)
        options.merge!(taxon_ids: taxon_ids)
      end

      search_options.merge!(with: options)
      search_options.merge!(conditions: cond_options)

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
