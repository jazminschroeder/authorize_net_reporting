# Gateway to connect with AuthorizeNetReporting API
require 'builder'
require 'httparty'
require 'date'
module AuthorizeNetReporting
  class Gateway
    include HTTParty
    headers 'Content-Type' => 'text/xml'
    format :xml
    #debug_output $stdout
  
    TEST_URL = "https://apitest.authorize.net/xml/v1/request.api"
    LIVE_URL = "https://api.authorize.net/xml/v1/request.api"
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
