namespace :ambitious_query_indexer do
  desc "Analyse application queries for index quality"
  task :analyse do
    
    # Load Rails environment
    RAILS_ENV = 'test'
    require File.join(RAILS_ROOT,'config','environment')
    
    # Load AQI
    require File.join(RAILS_ROOT,'vendor','plugins','ambitious_query_indexer','lib','ambitious_query_indexer')

    controller_root = File.join(RAILS_ROOT,'app','controllers')
    helper_root = File.join(RAILS_ROOT,'app','helpers')
    
    # No support for views at the moment. You haven't got queries coming from your views.... have you?! ;)
    
    indexer = AmbitiousQueryIndexer.new([controller_root, helper_root])
    indexer.analyse
  end
end