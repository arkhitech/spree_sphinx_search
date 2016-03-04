module Spree::Search
  class ThinkingSphinx < Spree::Core::Search::Base    
    def initialize(params)
      super(params)
      @properties[:shop] = params[:shop]

    end

    def retrieve_products
      set_base_scope
      curr_page = page || 1
      #      self.search_options.merge!(page: curr_page, per_page: per_page)

      #TODO need to implement show products without price
      #      unless Spree::Config.show_products_without_price
      #        @products = @products.where("spree_prices.amount IS NOT NULL").where("spree_prices.currency" => current_currency)
      #      end
      #      @products = @products.page(curr_page).per(per_page)
      
      @products = Spree::Product.search(self.escaped_query, search_options)
      @properties[:products] = @products
      @properties[:facets] = @products.facets
      @products = @products.page(curr_page).per(per_page)
      @products
      

    end
    
    protected 
    
    def search_options
      @search_options ||= {with: with, conditions: conditions}
    end
    
    def conditions
      @conditions ||= {}
    end
    
    def with
      @with ||= {}
    end
    
    def escaped_query
      @escaped_query ||= ''
    end
    
    def escaped_query=(query)
      @escaped_query = query
    end
    # method should return AR::Relations with conditions {:conditions=> "..."} for Product model
    def set_products_conditions_for(query)
      options = with     
      cond_options = conditions
      self.escaped_query = "#{query && Riddle.escape(query)}"
      self.escaped_query = '\\<' if self.escaped_query && self.escaped_query.strip == '<'
      
      if search
        if search[:price_range].present?
          price = search[:price_range].split(',')
          start_range = price[0].to_f
          end_range = price[1].to_f
          options.merge!(master_price: start_range..end_range)
        end
        if search[:price_range_from] || search[:price_range_to]
          start_range = search[:price_range_from].to_i
          end_range = search[:price_range_to] && search[:price_range_to].to_i || 100000
          options.merge!(master_price: start_range..end_range)
        end
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
          self.escaped_query << brand_search_query
          search_options[:match_mode] = :extended
          #          cond_options.merge!(brand: search[:brand_any])
        end  
        if search[:brand_ids].present?
          options.merge!(brand_ids: search[:brand_ids])
        end
        if search[:category_ids].present?
          options.merge!(category_ids: search[:category_ids])
        end
        if search[:taxon_ids].present?
          options.merge!(taxon_ids: search[:taxon_ids])
        end
        if search[:alphabet].present?
          alphabet_search_query = " (@name ^#{search[:alphabet]}*)"
          self.escaped_query << alphabet_search_query
          search_options[:match_mode] = :extended          
          
        end
        
        if search[:has_images]=='true'
          options.merge!(has_images: true)
        end
      end
      
      options.merge!(shop_ids: shop) if shop

      search_options.merge!(with: options)
      search_options.merge!(conditions: cond_options)
      #base_scope.where("#{Spree::Product.table_name}.id" => @properties[:product_ids])
    end

    def set_base_scope
      #base_scope = Spree::Product.active
      with[:is_active] = true
      #base_scope = base_scope.in_taxon(taxon) unless taxon.blank?
      if taxon
        if taxon.kind_of?(Array)
          taxon_ids=[]
          taxon.each do |t|
            taxon_ids += t.self_and_descendants.map(&:id)
          end
        else
          taxon_ids = taxon.self_and_descendants.map(&:id)
        end
        with.merge!(taxon_ids: taxon_ids)
      end
      set_products_conditions_for(keywords)
      #TODO search scopes to be implement
      #base_scope = add_search_scopes(base_scope)
            
      add_eagerload_scopes
    end

    def add_eagerload_scopes 
      if include_images
        #scope.eager_load({master: [:prices, :images]})
        search_options.merge!(sql: {include: {master: [:prices, :images]}})
      else
        #scope.includes(master: :prices)
        search_options.merge!(sql: {include: {master: [:prices]}})
      end
    end

    #TODO implement this to be sphinx compatible
    def add_search_scopes(base_scope)
      search.each do |name, scope_attribute|
        scope_name = name.to_sym
        if base_scope.respond_to?(:search_scopes) && base_scope.search_scopes.include?(scope_name.to_sym)
          base_scope = base_scope.send(scope_name, *scope_attribute)
        else
          base_scope = base_scope.merge(Spree::Product.ransack({scope_name => scope_attribute}).result)
        end
      end if search
      base_scope
    end
    
  end
end
