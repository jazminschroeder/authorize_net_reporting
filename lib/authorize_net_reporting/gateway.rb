require 'builder'
require 'httparty'
require 'date'
module AuthorizeNetReporting
  # Gateway to connect to Authorize.net web services in order to interact with Reporting API
  class Gateway
    include HTTParty
    headers 'Content-Type' => 'text/xml'
    format :xml
    
    # Authorize.net Developer TEST API 
    # Note: Authorize.net requires the use of a developer test payment gateway account, you may have to request one from Authorize.net Developer Center
    TEST_URL = "https://apitest.authorize.net/xml/v1/request.api"
    
    # Authorize.net Production API
    LIVE_URL = "https://api.authorize.net/xml/v1/request.api"
    
    # Authorize.net XML schema
    XMLNS    = "AnetApi/xml/v1/schema/AnetApiSchema.xsd"
    
    # Make Http request
    # param[String] xml api request     
    def send_xml(xml)
      begin
        Gateway.post(api_url, :body => xml)
      rescue
        nil
      end    
    end
    
    # Using test or live mode?
    def mode 
      @mode 
    end
    
    # AuthorizeNet API Url test/live
    def api_url
      mode.eql?('test') ? TEST_URL : LIVE_URL
    end
  end
end  
