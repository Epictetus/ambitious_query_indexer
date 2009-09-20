require 'modules/active_record_logger'

module ActiveRecord
  class Base
    extend SamdanaviaStudios::AmbitiousQueryIndexer::ActiveRecordLogger
    
    def self.find_by_sql_with_query_logging(sql)
      self.log_query(sql)
      self.find_by_sql_without_query_logging(sql)
    end
    
    class << self
      alias_method_chain :find_by_sql, :query_logging
    end
    
  end
  
  module ConnectionAdapters
    class MysqlAdapter
      def execute_with_query_logging(sql, name = nil)
        ActiveRecord::Base.log_query(sql, name) unless name.blank?
        execute_without_query_logging(sql, name)
      end
      
      alias_method_chain :execute, :query_logging
    end
  end
end
