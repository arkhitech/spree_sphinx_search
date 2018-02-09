Spree::Taxon.class_eval do

  after_save ThinkingSphinx::RealTime.callback_for(:product)
  
  def self.filters
    roots
  end

  def filter_options
    descendants
  end

end
