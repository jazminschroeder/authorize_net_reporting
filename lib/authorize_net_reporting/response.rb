module AuthorizeNetReporting
  # AuthorizeNetReporting::Response parses the response from Authorize.net API and turns results into objects setting attributes for easy integration
  class Response 
    extend Common
    def self.parse_settled_batch_list(response)
      batch_list = response["getSettledBatchListResponse"]["batchList"]["batch"]
      batches = []
      batch_list.each do |batch|
        statistics = extract_batch_statistics(batch)
        params = to_single_hash(batch)
        params.merge!("statistics" => statistics) unless statistics.blank?
        batches << create_class("Batch", params)
      end
      batches
    end
    
    # Parse response for batch_statistics API call
    def self.parse_batch_statistics(response)
      batch = response["getBatchStatisticsResponse"]["batch"]
      statistics = extract_batch_statistics(batch)
      params = to_single_hash(batch)
      params.merge!("statistics" => statistics) unless statistics.blank?
      batch = create_class("Batch", params)
    end
     
    # Parse response for transaction_list API call
    def self.parse_transaction_list(response)
      transactions = [response["getTransactionListResponse"]["transactions"]["transaction"]].flatten
      transaction_list = []
      transactions.each do |transaction|
        transaction_list << create_class("AuthorizeNetTransaction", to_single_hash(transaction))
      end
      transaction_list
    end

     
    # Parse response unsettled_transaction API call
    def self.parse_unsettled_transaction_list(response)
      unsettled_transactions = [response["getUnsettledTransactionListResponse"]["transactions"]["transaction"]]
      transactions = []
      unsettled_transactions.each do |transaction|
        transactions << create_class("AuthorizeNetTransaction", to_single_hash(transaction))
      end
      transactions
    end
    
    
    # Parse response transaction_details API call
    def self.parse_transaction_details(response)
      params = response["getTransactionDetailsResponse"]["transaction"]
      create_class("AuthorizeNetTransaction", to_single_hash(params))
    end
    
    # Handle batch statistics
    def self.extract_batch_statistics(batch)
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
    def self.to_single_hash(hash)
      hash.each do |key, value|
        case value       
          when Hash then to_single_hash(value)
          when String, Integer then   (@temp_hash||={})[underscore(key)] = value          
        end  
      end
      @temp_hash
    end
    
    #Create objects dinamicaly 
    def self.create_class(class_name, params)
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

