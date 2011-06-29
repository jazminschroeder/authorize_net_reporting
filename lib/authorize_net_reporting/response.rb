module AuthorizeNetReporting
module Response
  def self.parse(api_function, params)
    parser = Parser.new
    parser.send(api_function, params)
  end
  class Parser
    include AuthorizeNetReporting::Common
   # Parse response for settled_batch_list API call 
   def settled_batch_list(response)
      batch_list = response["getSettledBatchListResponse"]["batchList"]["batch"]
      batches = []
      batch_list.each do |batch|
        statistics = parse_batch_statistics(batch)
        params = to_single_hash(batch)
        params.merge!("statistics" => statistics) unless statistics.blank?
        batches << create_class("Batch", params)
       end
       batches
    end
    
    # Parse response for batch_statistics API call
    def batch_statistics(response)
      batch = response["getBatchStatisticsResponse"]["batch"]
      statistics = parse_batch_statistics(batch)
      params = to_single_hash(batch)
      params.merge!("statistics" => statistics) unless statistics.blank?
      batch = create_class("Batch", params)
    end
    
    # Parse response for transaction_list API call
    def transaction_list(response)
      transactions = [response["getTransactionListResponse"]["transactions"]["transaction"]].flatten
      transaction_list = []
      transactions.each do |transaction|
        transaction_list << create_class("AuthorizeNetTransaction", to_single_hash(transaction))
      end
      transaction_list
    end
    
    # Parse response unsettled_transaction API call
    def unsettled_transaction_list(response)
      unsettled_transactions = [response["getUnsettledTransactionListResponse"]["transactions"]["transaction"]]
      transactions = []
      unsettled_transactions.each do |transaction|
        transactions << create_class("AuthorizeNetTransaction", to_single_hash(transaction))
      end
      transactions
    end
    
    # Parse response transaction_details API call
    def transaction_details(response)
      params = response["getTransactionDetailsResponse"]["transaction"]
      create_class("AuthorizeNetTransaction", to_single_hash(params))
    end
    
    # Handle batch statistics
    def parse_batch_statistics(batch)
      statistics = []
      if batch["statistics"]
        batch_statistics = [batch["statistics"]["statistic"]].flatten
        batch_statistics.each do |statistic|   
          statistic = statistic.inject({}) {|h, (key,value)| h[underscore(key)] = value; h}
          statistics << statistic 
        end
      end
      statistics
    end
    
    # Convert response nested hash into a single hash
    # param[Hash] hash
    def to_single_hash(hash)
      hash.each do |key, value|
        case value       
          when Hash then to_single_hash(value)
          when String, Integer then   (@temp_hash||={})[underscore(key)] = value          
        end  
      end
      @temp_hash
    end
    
    #Create objects dinamicaly 
    def create_class(class_name, params)
      if Object.const_defined?(class_name)
        klass = Object.const_get(class_name)
      else  
        klass = Object.const_set(class_name, Class.new) 
        klass.class_eval do
          define_method(:initialize) do |params|
            params.each do |key, value| 
              self.class.__send__(:attr_accessor, key)
              instance_variable_set("@#{key}", value) 
            end  
          end  
        end
      end   
      klass.new(params)
    end
  end
end
end
