ThinkingSphinx::Index.define 'spree/product', with: :active_record do
  indexes :name, sortable: true
  indexes master.sku
  indexes :description
  indexes :meta_description
  indexes :meta_keywords

  indexes taxons.name, as: :taxon, facet: true
  has taxons.id, as: :taxon_ids

  group_by :available_on
end