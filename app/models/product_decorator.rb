Spree::Product.class_eval do
  class_attribute :indexed_options, :indexed_properties
  self.indexed_options = []
  # [{:name => :age_from, :type => :integer}]
  self.indexed_properties = []
  # Method should return array of hashes like [{:field => :created_at, :options => {:as => :recency}}]
  def self.indexed_attributes
    []
  end

  def self.sphinx_search_options &rules
    Spree::Search::ThinkingSphinx.send :define_method, :custom_options, rules
  end
end
