namespace :ambitious_query_indexer do
  desc "Analyse application queries for index quality"
  task :analyse do
    # Load Rails environment
    RAILS_ENV = 'test'
    require File.join(RAILS_ROOT,'config','environment')
    
    # Load AQI
    require File.join(RAILS_ROOT,'vendor','plugins','ambitious_query_indexer','lib','ambitious_query_indexer')
    
    tree = []
    tree << File.join(RAILS_ROOT,'app','controllers')  
    tree << File.join(RAILS_ROOT,'app','helpers')
    tree << File.join(RAILS_ROOT,'app','views')
    tree << File.join(RAILS_ROOT,'app','models')

    scan_results = QueryScanner.parse(tree)
    
    puts SummaryReport.view(:results => scan_results)
  end

  desc "Analyze application queries for index quality for US English speakers"
  task :analyze do
    Rake::Task["ambitious_query_indexer:analyse"].execute
  end
end