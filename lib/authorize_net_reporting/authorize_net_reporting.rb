class AuthorizeNetReporting < Gateway
  include Common
  def initialize(options = {})
    requires!(options, :mode, :key, :login)
    @mode, @key, @login = options[:mode], options[:key], options[:login]
  end
  
  def transaction_details(transaction_id)
    xml = build_request('getTransactionDetailsRequest', {:transaction_id => transaction_id})
    response = send_xml(xml)
    response_message = get_response_message(response, 'getTransactionDetailsResponse')
    if success?
      ::Response.parse('transaction_details',response.parsed_response)  
    else
      raise StandardError, response_message
    end    
  end
  
  def settled_batch_list(options = {})
    xml = build_request('getSettledBatchListRequest',  options)
    response = send_xml(xml)
    response_message = get_response_message(response, 'getSettledBatchListResponse')    
    if success?
      ::Response.parse('batch_list', response.parsed_response)
    else
      raise StandardError, response_message
    end  
  end
  
  private
  def requires!(hash, *params)
    params.each do |param|
      raise ArgumentError, "Missing Required Parameter #{param}" unless hash.has_key?(param) 
    end
  end

  #Valid Request Types
  #getTransactionDetailsRequest
  def build_request(request_type, options = {})
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!(:xml, :version => '1.0', :encoding => 'utf-8')
    xml.tag!(request_type, :xmlns => XMLNS) do 
      xml.tag!('merchantAuthentication') do
        xml.tag!('name', @login)
        xml.tag!('transactionKey', @key)
      end
      send("build_#{underscore(request_type)}", xml, options)
    end  
  end
  
  def build_get_transaction_details_request(xml, options)
    xml.tag!('transId', options[:transaction_id])
    xml.target!
  end
  
  def build_get_settled_batch_list_request(xml, options)
    xml.tag!("includeStatistics", true) #if options[:include_statistics]
    if options[:first_settlement_date] and options[:last_settlement_date]
      xml.tag!("firstSettlementDate", Date.parse(options[:first_settlement_date]).strftime("%Y-%m-%dT00:00:00Z"))
      xml.tag!("lastSettlementDate", Date.parse(options[:last_settlement_date]).strftime("%Y-%m-%dT00:00:00Z"))
    end  
    xml.target!
  end

  
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
