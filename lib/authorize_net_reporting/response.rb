module AuthorizeNetReporting
  # AuthorizeNetReporting::Response parses the response from Authorize.net API and turns results into objects setting attributes for easy integration
  
  class Response 
    # Parse response for settled_batch_list 
    def self.parse_settled_batch_list(response)
      batches = []
      unless response[:get_settled_batch_list_response][:batch_list].nil?
        batch_list = [response[:get_settled_batch_list_response][:batch_list][:batch]].flatten
        batch_list.each do |batch|
          batch.merge!(:statistics => [batch[:statistics][:statistic]].flatten) unless batch[:statistics].nil?
          batches << create_class("Batch", batch)
        end
      end
      batches
    end
    
    # Parse response for batch_statistics
    def self.parse_batch_statistics(response)
      return nil if response[:get_batch_statistics_response][:batch].nil?
      batch = response[:get_batch_statistics_response][:batch]
      batch.merge!(:statistics => [batch[:statistics][:statistic]].flatten) unless batch[:statistics].nil?
      create_class("Batch", batch)
    end
     
    # Parse response for transaction_list 
    def self.parse_transaction_list(response)
      transactions = []
      unless response[:get_transaction_list_response][:transactions].nil?
        transaction_list = [response[:get_transaction_list_response][:transactions][:transaction]].flatten
        transaction_list.each do |transaction|
          transactions << create_class("AuthorizeNetTransaction", transaction)
        end  
      end
     transactions
    end

     
    # Parse response unsettled_transaction 
    def self.parse_unsettled_transaction_list(response)
      transactions = []
      unless response[:get_unsettled_transaction_list_response][:transactions].nil?
        unsettled_transactions = [response[:get_unsettled_transaction_list_response][:transactions][:transaction]].flatten
        unsettled_transactions.each do |transaction|
          transactions << create_class("AuthorizeNetTransaction", transaction)
        end
      end  
     transactions
    end
    
    
    # Parse response transaction_details 
    def self.parse_transaction_details(response)
      return nil if response[:get_transaction_details_response][:transaction].nil?
      transaction =  response[:get_transaction_details_response][:transaction] 
      create_class("AuthorizeNetTransaction", transaction)
    end
    
    # Convert response nested hash into a single hash
    # param[Hash] hash
    def self.to_single_hash(hash, first_iteration = nil)
      @temp_hash = {}  if first_iteration == true
      hash.each do |key, value|
        case value       
          when Hash then to_single_hash(value)
          when String, Integer, Array then @temp_hash[key] = value          
        end  
      end
      @temp_hash
    end
    
    #Create objects dinamically 
    def self.create_class(class_name, params)
      params = to_single_hash(params, true)
      if AuthorizeNetReporting.const_defined?(class_name)
        klass = AuthorizeNetReporting.const_get(class_name)
      else  
        klass = AuthorizeNetReporting.const_set(class_name, Class.new) 
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

