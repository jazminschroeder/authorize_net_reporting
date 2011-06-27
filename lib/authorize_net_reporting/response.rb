module Response
  def self.parse(api_function, params)
    parser = Parser.new
    parser.send(api_function, params)
  end
  class Parser
    include Common
    def settled_batch_list(response)
      batch_list = response["getSettledBatchListResponse"]["batchList"]["batch"]
      batches = []
      batch_list.each do |batch|
        statistics = parse_batch_statistics(batch)
        params = batch.to_single_hash
        params.merge!("statistics" => statistics) unless statistics.blank?
       batch = create_class("Batch",params)
        raise batch.inspect
        batches << create_class("Batch", params)
       end
       batches
    end
    
    def batch_statistics(response)
      batch = response["getBatchStatisticsResponse"]["batch"]
      statistics = parse_batch_statistics(batch)
      params = batch.to_single_hash
      params.merge!("statistics" => statistics) unless statistics.blank?
      batch = Batch.new(params)
    end
    
    def transaction_list(response)
      transactions = response["getTransactionListResponse"]["transactions"]["transaction"]
      transaction_list = []
      transactions.each do |transaction|
        transaction_list << AuthorizeNetTransaction.new(transaction.to_single_hash)
      end
      transaction_list
    end
    
    def unsettled_transaction_list(response)
      unsettled_transactions = response["getUnsettledTransactionListResponse"]["transactions"]["transaction"]
      unsettled_transactions = [unsettled_transactions].flatten
      transactions = []
      unsettled_transactions.each do |transaction|
        transactions << AuthorizeNetTransaction.new(transaction.to_single_hash)
      end
      transactions
    end
    
    def transaction_details(response)
      params = response["getTransactionDetailsResponse"]["transaction"].to_single_hash
      AuthorizeNetTransaction.new(params)
    end
    
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
    
    def create_class(class_name, hash)
       klass = Object.const_set(class_name, Class.new) 
       klass.class_eval do
          attr_accessor hash.keys
          def initialize
           
          end
       end
       klass.new
    end

  end
end

class Hash
  def to_single_hash(hash = self)
    hash.each do |key, value|
      case value       
        when Hash then to_single_hash(value)
        when String, Integer then   (@temp_hash||={})[key] = value          
      end  
    end
    @temp_hash
  end
end

class AuthorizeNetTransaction 
  include Common
  def initialize(params)
    params.each do |key, value|
      self.class.__send__(:attr_accessor, underscore(key))
      instance_variable_set("@#{underscore(key)}", value)
    end  
  end
end

class Batch 
  include Common
  def initialize(params)
    params.each do |key, value|        
      self.class.__send__(:attr_accessor, underscore(key))
      instance_variable_set("@#{underscore(key)}", value)
    end  
  end
end


