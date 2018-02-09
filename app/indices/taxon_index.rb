ThinkingSphinx::Index.define('spree/taxon', with: :real_time) do    
    indexes :name, sortable: true
    has :parent_id, type: :integer
    has :taxonomy_id, type: :integer
  end