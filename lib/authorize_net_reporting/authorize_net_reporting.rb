class AuthorizeNetReporting < Gateway
  include Common
  def initialize(options = {})
    requires!(options, :mode, :key, :login)
    @mode, @key, @login = options[:mode], options[:key], options[:login]
  end
  
  # Returns all settled batches within specified date range
  # @params [Hash] options {:first_settlement_date => "2011/04/20", :last_settlement_date => "2011/05/20"}
  def settled_batch_list(options = {})
    process_request(__method__, options)
  end
  
  # Returns statistics for specify batch
  # @params [Integer] batch_id
  def batch_statistics(batch_id)
    process_request(__method__, {:batch_id => batch_id})
  end  
  
  # Returns all transactions in a specified batch
  # @params [Integer] batch_id
  def transaction_list(batch_id)
    process_request(__method__, {:batch_id => batch_id})
  end
  
  # Returns data for unsettled transactions. This API function return data for up to 1000 of the most recent transactions
  def unsettled_transaction_list
    process_request(__method__)
  end
  
  # Get detailed information about one specific transaction
  # @params [Integer] transaction_id, The transaction ID
  def transaction_details(transaction_id)
    process_request(__method__, {:transaction_id => transaction_id})
  end  

  private
  # Process request
  # @params [Symbol] api_function requested, ':settled_batch_list', ':batch_statistics', ':transaction_details', ':transactions_list' 
  # @params [Hash] options, options to be passed to API request, '{:batch_id => 12345}'  
  def process_request(api_function, options = {})
    xml = build_request(api_function, options)
    response = send_xml(xml)
    handle_response(api_function,response)
  end

  def requires!(hash, *params)
    params.each do |param|
      raise ArgumentError, "Missing Required Parameter #{param}" unless hash.has_key?(param) 
    end
  end
  
  #Valid Request Types
  #getTransactionDetailsRequest
  #getSettledBatchListRequest
  #getBatchStatisticsRequest
  def build_request(api_function, options = {})
    api_request = "get#{camelize(api_function.to_s)}Request"
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!(:xml, :version => '1.0', :encoding => 'utf-8')
    xml.tag!(api_request, :xmlns => XMLNS) do 
      xml.tag!('merchantAuthentication') do
        xml.tag!('name', @login)
        xml.tag!('transactionKey', @key)
      end
      send("build_#{underscore(api_request)}", xml, options)
    end  
  end
  
  def build_get_settled_batch_list_request(xml, options)
    xml.tag!("includeStatistics", true) if options[:include_statistics]
    if options[:first_settlement_date] and options[:last_settlement_date]
      xml.tag!("firstSettlementDate", Date.parse(options[:first_settlement_date]).strftime("%Y-%m-%dT00:00:00Z"))
      xml.tag!("lastSettlementDate", Date.parse(options[:last_settlement_date]).strftime("%Y-%m-%dT00:00:00Z"))
    end  
    xml.target!
  end
  
  def build_get_batch_statistics_request(xml, options)
    xml.tag!("batchId", options[:batch_id])
    xml.target!
  end
  
  def build_get_transaction_list_request(xml, options)
    xml.tag!("batchId", options[:batch_id])
    xml.target!
  end

  def build_get_unsettled_transaction_list_request(xml, options)
    xml.target!
  end
  
  def build_get_transaction_details_request(xml, options)
    xml.tag!('transId', options[:transaction_id])
    xml.target!
  end
   
  def handle_response(api_function, response) 
    response_message = get_response_message(api_function, response)
    success? ? ::Response.parse(api_function,response.parsed_response) : (raise StandardError, response_message)
  end
  
  def get_response_message(api_function, response)
    api_response = "get#{camelize(api_function.to_s)}Response"
    if response.parsed_response[api_response] 
      message = response.parsed_response[api_response]["messages"]["message"]["text"]
      @success = true if message =~ /Successful/
    else
      message = response.parsed_response["ErrorResponse"]["messages"]["message"]["text"] rescue "Unable to execute transaction"
    end    
    message
  end
    
  def success?
    @success == true
  end
  
end
