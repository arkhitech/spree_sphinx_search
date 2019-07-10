ThinkingSphinx::Configuration.instance.indices.reject!{|i| i.reference == :'spree/howmuch_shop'}
ThinkingSphinx::Index.define('spree/howmuch_shop', with: :active_record, delta: ThinkingSphinx::Deltas::SidekiqDelta) do
    
    is_active_sql = "(#{Spree::HowmuchShop.table_name}.deleted_at IS NULL AND #{
      Spree::HowmuchShop.table_name}.published_at IS NOT NULL AND #{
      Spree::HowmuchShop.table_name}.approved_at IS NOT NULL)"
    indexes :name, sortable: true
    indexes :description
    indexes store.address.phone, as: :phone
    indexes store.address.alternative_phone, as: :alternative_phone
    
    indexes store.address.address1, as: :address1
    indexes store.address.address2, as: :address2
    
  
    indexes store.address.city, as: :city_name
    indexes store.address.zipcode, as: :zipcode
    
    indexes store.address.state_name, as: :state_name
    
    has longitude, latitude
      
    has 'published_at IS NOT NULL', as: :published, type: :boolean
    has 'approved_at IS NOT NULL', as: :approved, type: :boolean
    has is_active_sql, as: :is_active, type: :boolean
    
    has store.address.state_id, as: :state_id
    has store.address.country_id, as: :country_id
  end