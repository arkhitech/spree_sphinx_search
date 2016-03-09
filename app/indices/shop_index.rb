ThinkingSphinx::Index.define 'spree/howmuch_shop', with: :active_record do
    
    indexes :name, sortable: true
    indexes :address
    indexes :description
    
    has longitude, latitude
    
    has products.id, as: :product_ids, facet: true  
    has variants.id, as: :variant_ids, facet: true  
  
    has :is_authentic, type: :boolean
    
  end