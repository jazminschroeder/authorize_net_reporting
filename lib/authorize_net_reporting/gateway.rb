require 'builder'
require 'httparty'
class Gateway
  include HTTParty
  include Common
  headers 'Content-Type' => 'text/xml'
  format :xml
  #debug_output $stdout
  
  TEST_URL = "https://apitest.authorize.net/xml/v1/request.api"
  LIVE_URL = "https://api.authorize.net/xml/v1/request.api"
  XMLNS    = "AnetApi/xml/v1/schema/AnetApiSchema.xsd"
  
  def send_xml(xml)
    begin
      Gateway.post(api_url, :body => xml)
    rescue
      nil
    end    
  end
  
  def mode
    @mode
  end
  
  def api_url
    mode.eql?('test') ? TEST_URL : LIVE_URL
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
    xml.tag!("includeStatistics", true) if options[:include_statistics]
    if options[:first_settlement_date] and options[:last_settlement_date]
      xml.tag!("firstSettlementDate", options[:first_settlement_date])
      xml.tag!("lastSettlementDate", options[:last_settlement_date])
    end  
    xml.target!
    
  end
  
end
  