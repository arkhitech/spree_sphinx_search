ThinkingSphinx::Index.define('spree/variant', with: :active_record, delta: ThinkingSphinx::Deltas::SidekiqDelta) do
    #is_active_sql = "(spree_products.deleted_at IS NULL AND spree_products.available_on <= NOW() #{'AND (spree_products.count_on_hand > 0)' unless Spree::Config[:allow_backorders]} )"
    
    is_active_sql = "(#{Spree::Variant.table_name}.deleted_at IS NULL)"   
    option_sql = lambda do |option_name|
      sql = <<-eos
        SELECT DISTINCT p.id, ov.id
        FROM #{Spree::OptionValue.table_name} AS ov
        LEFT JOIN #{Spree::OptionType.table_name} AS ot ON (ov.option_type_id = ot.id)
        LEFT JOIN spree_option_values_variants AS ovv ON (ovv.option_value_id = ov.id)
        LEFT JOIN #{Spree::Variant.table_name} AS v ON (ovv.variant_id = v.id)
        WHERE (ot.name = '#{option_name}' AND v.id>=$start AND v.id<=$end);
        #{source.to_sql_query_range}
      eos
      sql.gsub("\n", ' ').gsub('  ', '')
    end

    property_sql = lambda do |property_name|
      sql = <<-eos
          (SELECT spp.value
          FROM #{Spree::ProductProperty.table_name} AS spp
          INNER JOIN #{Spree::Property.table_name} AS sp ON sp.id = spp.property_id
          WHERE sp.name = '#{property_name}' AND spp.product_id = #{Spree::Product.table_name}.id)
      eos
      sql.gsub("\n", ' ').gsub('  ', '')
    end
    
    
    
    indexes "array_to_string(array_agg(DISTINCT #{Spree::Product.table_name}.name), ' ')", as: :name, sortable: true #changed
    #indexes master.sku
    # change #indexes "array_to_string(array_agg(DISTINCT #{Spree::Variant.table_name}.sku), ' ')", as: :variant_skus
#    indexes variants_including_master.sku, as: :variant_skus
    indexes "array_to_string(array_agg(DISTINCT #{Spree::Product.table_name}.description), ' ')", as: :description
    #indexes :meta_description
    #indexes :meta_keywords
    
    ##################
    indexes sku, as: :variant_skus
    join images
    has "(COUNT(#{Spree::Image.table_name}.id) > 0)", as: :has_images, type: :boolean  
    #################
  
  

    indexes "array_to_string(array_agg(DISTINCT #{Spree::Taxon.table_name}.name), ' ')", as: :taxon_name
#    indexes taxons.name, as: :taxon_name
    indexes "array_to_string(array_agg(DISTINCT (CASE WHEN #{Spree::Taxon.table_name}.taxonomy_id = #{Spree::Product.taxonomy_brand.id} THEN #{Spree::Taxon.table_name}.name ELSE NULL END)), ' ')", as: :brand_name
#    indexes brand_taxons.name, as: :brand_name
        
#    has product.taxons.id, as: :taxon_ids, facet: true  
    has "array_to_string(array_agg(DISTINCT #{Spree::Taxon.table_name}.id), ' ')", as: :taxon_ids, multi: true, type: :integer, facet: true
    
    
    has "array_to_string(array_agg(DISTINCT (CASE WHEN #{Spree::Taxon.
    table_name}.taxonomy_id = #{Spree::Product.taxonomy_brand.id} THEN #{Spree::
    Taxon.table_name}.id ELSE NULL END)), ' ')", as: :brand_ids, multi: true, type: :integer, facet: true
#    has brand_taxons.id, as: :brand_ids, facet: true  
    has "array_to_string(array_agg(DISTINCT (CASE WHEN #{Spree::Taxon.
    table_name}.taxonomy_id = #{Spree::Product.taxonomy_category.id} THEN #{Spree::
    Taxon.table_name}.id ELSE NULL END)), ' ')", as: :category_ids, multi: true, type: :integer, facet: true
#    has category_taxons.id, as: :category_ids, facet: true  
     
#change #    join variant_images
#    has "(COUNT(#{Spree::Image.table_name}.id) > 0)", as: :has_images, type: :boolean  
    
    #has properties.name
  #  has variant.price , as: :price
#  has variant.original_price , as: :original_price
    
#    has master.default_price.amount, type: :float, as: :master_price
    is_active_shop_sql = "(#{Spree::HowmuchShop.table_name}.deleted_at IS NULL AND #{
      Spree::HowmuchShop.table_name}.is_authentic = 't')"
    join "LEFT OUTER JOIN #{Spree::ShopVariantPrice.table_name} ON #{
          Spree::ShopVariantPrice.table_name}.variant_id = #{Spree::Variant.table_name}.id LEFT OUTER JOIN #{
          Spree::HowmuchShop.table_name} ON #{
          Spree::ShopVariantPrice.table_name}.shop_id = #{Spree::HowmuchShop.table_name}.id AND #{
          is_active_shop_sql} LEFT OUTER JOIN #{Spree::Address.table_name} ON #{
          Spree::HowmuchShop.table_name}.address_id = #{Spree::Address.table_name
          }.id LEFT OUTER JOIN #{Spree::Product.table_name} ON #{
          Spree::Product.table_name}.id = #{Spree::Variant.table_name
          }.product_id LEFT OUTER JOIN spree_products_taxons ON spree_products_taxons.product_id = #{Spree::Product.table_name
          }.id LEFT OUTER JOIN #{Spree::Taxon.table_name} ON #{Spree::Taxon.table_name}.id = spree_products_taxons.taxon_id"
          
    has "(COUNT(#{Spree::HowmuchShop.table_name}.id) > 0)", as: :has_shops, type: :boolean  
  
    has "array_to_string(array_agg(DISTINCT #{Spree::Address.table_name}.country_id), ',')", 
      multi: true, type: :integer, as: :country_ids
  
    has "array_to_string(array_agg(DISTINCT #{Spree::ShopVariantPrice.table_name}.price), ',')", 
      multi: true, type: :bigint, as: :shop_prices
#    has shop_variant_prices.price, type: :bigint, as: :shop_prices
    has "array_to_string(array_agg(DISTINCT #{Spree::ShopVariantPrice.table_name}.shop_id), ',')", 
      multi: true, type: :integer, as: :shop_ids
#    has shop_variant_prices.shop_id, as: :shop_ids, facet: true
#    
    #when searching for price range inside shop, we need to get price of product within the shop 
    has "array_to_string(array_agg(DISTINCT #{Spree::ShopVariantPrice.table_name}.shop_and_price), ',')", 
      multi: true, type: :bigint, as: :shop_and_prices
#    has shop_variant_prices.shop_and_price, as: :shop_and_prices
    #group_by "spree_prices.amount"
#    group_by :available_on
    #group_by "#{Spree::ProductProperty.table_name}.name"
    has is_active_sql, as: :is_active, type: :boolean

    #has "CRC32(#{property_sql.call('Brand')}", as: :brand, type: :integer, facets: true
    
#    source.model.indexed_attributes.each do |attr|
#      has attr[:field], attr[:options]
#    end
#    source.model.indexed_properties.each do |prop|
#      has property_sql.call(prop[:name].to_s), :as => :"#{prop[:name]}_property", :type => prop[:type]
#    end
#    source.model.indexed_options.each do |opt|
#      has option_sql.call(opt.to_s), :as => :"#{opt}_option", :source => :ranged_query, type: :multi, :facet => true
#    end
  end