namespace :ambitious_query_indexer do
  desc "Analyse application queries for index quality"
  task :analyze do
    
    # Load Rails environment
    RAILS_ENV = 'test'
    require File.join(RAILS_ROOT,'config','environment')
    
    # Load AQI
    require File.join(RAILS_ROOT,'vendor','plugins','ambitious_query_indexer','lib','ambitious_query_indexer')
    
    tree = []
    tree << File.join(RAILS_ROOT,'app','controllers')  
    tree << File.join(RAILS_ROOT,'app','helpers')
    tree << File.join(RAILS_ROOT,'app','views')

    indexer = AmbitiousQueryIndexer.new(tree)
    indexer.analyse
  end
end