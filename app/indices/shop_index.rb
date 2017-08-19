ThinkingSphinx::Index.define('spree/howmuch_shop', with: :active_record, delta: ThinkingSphinx::Deltas::SidekiqDelta) do
    
    is_active_sql = "(#{Spree::HowmuchShop.table_name}.deleted_at IS NULL AND #{Spree::HowmuchShop.table_name}.published_at IS NOT NULL)"
    indexes :name, sortable: true
    indexes :description
    
    indexes address.address1, as: :address1
    indexes address.address2, as: :address2
    
    indexes address.city, as: :city_name
    
    has longitude, latitude
      
    has 'published_at IS NOT NULL', as: :published, type: :boolean
    has 'approved_at IS NOT NULL', as: :approved, type: :boolean
    has is_active_sql, as: :is_active, type: :boolean
    has address.country_id, as: :country_id
  end