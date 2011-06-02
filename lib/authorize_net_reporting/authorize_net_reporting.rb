class AuthorizeNetReporting < Gateway
  
  def initialize(options = {})
    requires!(options, :mode, :key, :login)
    @mode, @key, @login = options[:mode], options[:key], options[:login]
  end
  
  def transaction_details(transaction_id)
    xml = build_request('getTransactionDetailsRequest', {:transaction_id => transaction_id})
    response = send_xml(xml)
    response_message = get_response_message(response, 'getTransactionDetailsResponse')
    if success?
      parsed_response = response.parsed_response.to_single_hash.reject{|key, value| ["xmlns:xsi","xmlns:xsd", "xmlns"].include? key}
      AuthorizeNetTransaction.new(parsed_response)
    else
      raise StandardError, response_message
    end    
  end
  
  def settled_batch_list(options = {})
    xml = build_request('getSettledBatchListRequest',  options)
    response = send_xml(xml)
    response_message = get_response_message(response, 'getSettledBatchListResponse')    
    if success?
      #TODO 
    else
      raise StandardError, response_message
    end  
  end
  
  private
  def get_response_message(response, transaction_type)
    if response.parsed_response[transaction_type] 
      message = response.parsed_response[transaction_type]["messages"]["message"]["text"]
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