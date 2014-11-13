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
      escaped_query = "#{query && Riddle.escape(query)}"
      escaped_query = '\\<' if escaped_query && escaped_query.strip == '<'
      
      if search
        if search[:price_range_any].present?
          start_range = 50000.0
          end_range = 0
          search[:price_range_any].each do |price_range|
            case price_range
            when /above.*0/i
              start_range = 1.0 if start_range > 1.0              
              end_range = 50000.0 if end_range < 50000
            when /under.*10/i
              start_range = 0.0 if start_range > 0.0
              end_range = 10.0 if end_range < 10.0
            when /10.*15/i
              start_range = 10.0 if start_range > 10.0
              end_range = 15.0 if end_range < 15.0
            when /15.*18/i
              start_range = 15.0 if start_range > 15.0
              end_range = 18.0 if end_range < 18.0
            when /18.*20/i
              start_range = 18.0 if start_range > 18.0
              end_range = 20.0 if end_range < 20.0
            when /20.*over/i
              start_range = 20.0 if start_range > 20.0
              end_range = 50000.0 if end_range < 50000.0
            else
  #            unless Spree::Config.show_products_without_price
  #              options.merge!(price: 0.001..500000.0)
  #            end          
            end
          end
          options.merge!(price: start_range..end_range)          
        else
#          unless Spree::Config.show_products_without_price
#            options.merge!(price: 0.001..500000.0)
#          end                    
        end
        if search[:brand_any].present?
          brands = search[:brand_any]
          brand_search_query = brands.join('"| @brand "')
          brand_search_query = " (@brand \"#{brand_search_query}\")"
          escaped_query << brand_search_query
          search_options[:match_mode] = :extended
         
          
           
#          cond_options.merge!(brand: search[:brand_any])
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
      product_ids = Spree::Product.search_for_ids(escaped_query, search_options)
      
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
