require 'classes/query'

module SamdanaviaStudios
  module AmbitiousQueryIndexer
    module ActiveRecordLogger
      @@saved_queries = []

      def log_query(sql, name = nil)
        @@saved_queries << Query.new(:sql => sql, :name => name)
      end
  
      def saved_queries
        @@saved_queries
      end
    end
  end
end