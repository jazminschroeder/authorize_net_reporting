require 'builder'
require 'httparty'
require 'date'
class Gateway
  include HTTParty
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
end
  
