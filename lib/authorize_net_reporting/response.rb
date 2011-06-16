module Response
  def self.parse(response_type, params)
    parser = Parser.new
    parser.send(response_type, params)
  end
  class Parser
    include Common
    def transaction_details(response)
      params = response["getTransactionDetailsResponse"]["transaction"].to_single_hash
      AuthorizeNetTransaction.new(params)
    end

    def batch_list(response)
      batch_list = response["getSettledBatchListResponse"]["batchList"]["batch"]
      batches = []
      batch_list.each do |batch|
        statistics = parse_batch_statistics(batch)
        params = batch.to_single_hash
        params.merge!("statistics" => statistics) unless statistics.blank?
        batches << Batch.new(params)
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


