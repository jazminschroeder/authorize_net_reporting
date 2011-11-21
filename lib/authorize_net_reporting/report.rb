# AuthorizeNetReporting::Report
module AuthorizeNetReporting
  #Handeling Errors
  class Error < StandardError; end
  # Initialize AuthorizeNetReporting::Report class
  #
  # report = AuthorizeNetReporting::Report.new({ :mode => ['test'|'live'], :key => 'your api key', :login => 'your api_login' })  
  class Report < Gateway
    attr_accessor :debug
    # Set API login, password and mode(live/test)
    #
    # AuthorizeNetReporting::Report.new({ :mode => ['test'|'live'], :key => 'your api key', :login => 'your api_login' })    
    # @param [Hash] { :mode => ['test'|'live'], :key => 'your api key', :login => 'your api_login' }    
    def initialize(options = {})
      requires!(options, :mode, :key, :login)
      @mode, @key, @login = options[:mode], options[:key], options[:login]
    end
  
    # Authorize.net API function: getSettledBatchListRequest 
    # 
    # This function returns Batch ID, Settlement Time, & Settlement State for all settled batches with a range of dates. 
    # optionally you can include __:include_statistics => true__ to receive batch statistics by payment type and batch totals. 
    # 
    # If no dates are specified, then the default is the last 24 hours.
    # @param [Hash] options { :first_settlement_date => "2011/04/20", :last_settlement_date => "2011/05/20", :include_statistics => true }
    def settled_batch_list(options = {})
      process_request(__method__, options)
    end
  
    # Authorize.net API function getBatchStatisticsRequest
    #    
    # Returns statistics for a single batch, specified by the batch ID.
    # @param [Integer] batch_id
    def batch_statistics(batch_id)
      process_request(__method__, {:batch_id => batch_id})
    end  
  
    # Authorize.net API function getTransactionListRequest
    #    
    # Returns data for all transactions in a specified batch.
    # @param [Integer] batch_id
    def transaction_list(batch_id)
      process_request(__method__, {:batch_id => batch_id})
    end
  
    # Authorize.net API function getUnsettledTransactionListRequest
    #     
    # Returns data for unsettled transactions. This API function return data for up to 1000 of the most recent transactions
    def unsettled_transaction_list
      process_request(__method__)
    end
  
    # Authorize.net API function getTransactionDetailsRequest
    #     
    # Get detailed information about one specific transaction
    # @param [Integer] transaction_id, The transaction ID
    def transaction_details(transaction_id)
      process_request(__method__, {:transaction_id => transaction_id})
    end  

    private
    # Process request
    # @param [Symbol] api_function requested, ':settled_batch_list', ':batch_statistics', ':transaction_details', ':transactions_list' 
    # @param [Hash] options, options to be passed to API request, '{:batch_id => 12345}'  
    def process_request(api_function, options = {})
      xml = build_request(api_function, options)
      api_response = send_xml(xml)
      puts api_response if @debug 
      response = parse_response(api_response)
      if success?(response["get_#{api_function.to_s}_response".to_sym])
        AuthorizeNetReporting::Response.send("parse_#{api_function}", response)
      else
        raise AuthorizeNetReporting::Error, error_message(response["get_#{api_function.to_s}_response".to_sym])
      end  
    end
  
    # Validates that required parameters are present
    # @param [Hash] hash 
    # @param [Symbol] params required :mode, :key
    def requires!(hash, *params)
      params.each do |param|
        raise AuthorizeNetReporting::Error, "Missing Required Parameter #{param}" unless hash.has_key?(param) 
      end
    end
  
    # Build xml request file for specified API function and options requested
    # @param[String], api_fundtion requested ':settled_batch_list', 'batch_statistics', ':transaction_details', ':transactions_list'
    # @param [Hash] options, options to be passed to API request, '{:batch_id => 12345}' 
    def build_request(api_function, options = {})
      api_request = "get#{camelize(api_function.to_s)}Request"
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!(:xml, :version => '1.0', :encoding => 'utf-8')
      xml.tag!(api_request, :xmlns => XMLNS) do 
        xml.tag!('merchantAuthentication') do
          xml.tag!('name', @login)
          xml.tag!('transactionKey', @key)
        end
        send("build_#{underscorize(api_request)}", xml, options)
      end  
    end
  
    def build_get_settled_batch_list_request(xml, options) #:nodoc:
      xml.tag!("includeStatistics", true) if options[:include_statistics]
      if options[:first_settlement_date] and options[:last_settlement_date]
        xml.tag!("firstSettlementDate", Date.parse(options[:first_settlement_date]).strftime("%Y-%m-%dT00:00:00Z")) 
        xml.tag!("lastSettlementDate", Date.parse(options[:last_settlement_date]).strftime("%Y-%m-%dT00:00:00Z"))
      end  
      xml.target!
    end
  
    def build_get_batch_statistics_request(xml, options) #:nodoc:
      xml.tag!("batchId", options[:batch_id])
      xml.target!
    end
  
    def build_get_transaction_list_request(xml, options) #:nodoc:
      xml.tag!("batchId", options[:batch_id])
      xml.target!
    end

    def build_get_unsettled_transaction_list_request(xml, options) #:nodoc:
      xml.target!
    end
  
    def build_get_transaction_details_request(xml, options) #:nodoc:
      xml.tag!('transId', options[:transaction_id])
      xml.target!
    end
  
    # Extract response message from response for specified api_function
    def success?(api_response_message)
      !api_response_message.nil? and (!api_response_message[:messages][:result_code].match(/ok/i).nil? or api_response_message[:messages][:message][:text].match(/cannot be found/i))
    end
    
    # @returns error message from API if request is not successful
    def error_message(api_response_message)
      api_response_message[:messages][:message][:text] rescue "Unable to process request. Try with debug = true"
    end
    
    # Parse response, convert keys to underscore symbols
    def parse_response(response)
      response = sanitize_response_keys(response.parsed_response)
    end

    # Recursively sanitizes the response object by clenaing up any hash keys.
    def sanitize_response_keys(response)
      if response.is_a?(Hash)
        response.inject({}) { |result, (key, value)| result[underscorize(key).to_sym] = sanitize_response_keys(value); result } 
      elsif response.is_a?(Array)
        response.collect { |result| sanitize_response_keys(result) }
      else
        response
      end
    end
    
    #helper method
    def underscorize(key) #:nodoc:
      key.to_s.sub(/^(v[0-9]+|ns):/, "").gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase
    end
    
    #helper method
    def camelize(str)
      str.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
    
  end
end
