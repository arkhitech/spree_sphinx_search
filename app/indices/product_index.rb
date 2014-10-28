ThinkingSphinx::Index.define 'spree/product', with: :active_record do
  indexes :name, sortable: true
  indexes master.sku
  indexes variants.sku, as: :variant_skus
  indexes :description
  indexes :meta_description
  indexes :meta_keywords

  indexes taxons.name, as: :taxon_name
  has taxons.id, as: :taxon_ids, facet: true  
#  has variant.price , as: :price
#  has variant.original_price , as: :original_price

  group_by :available_on
end