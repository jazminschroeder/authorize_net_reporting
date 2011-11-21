# Auhtorize.Net Reporting API 

For more information about the API visit [Authorize.net Reporting API](http://developer.authorize.net/api/transaction_details/).

In order to use the API you will need to apply for development and production credentials. 

Note: You will be able to view test transactions at [https://sandbox.authorize.net](https://sandbox.authorize.net/).
 
# Installation
    #Rails 3.x Add to your Gemfile and run bundle install
    gem 'authorize_net_reporting'
    
    #Or
    gem install 'authorize_net_reporting'

# Documentation
[Click here to view the Documentation](http://rubydoc.info/github/jazminschroeder/authorize_net_reporting/master/frames/)

# Usage example
**Create an AuthorizeNetReporting::Report object with your key/login**


    ~$ require 'rubygems'

    ~$ require 'authorize_net_reporting'

    ~$ report = AuthorizeNetReporting::Report.new({ :mode => 'test', :key => 'your_developer_api_key', :login => 'your_developer_api_login' })  
    
    => #<AuthorizeNetReporting::Report:0x007fd94b2dd7b0 @mode="test", @key="9Z6H2PybfGEp884J", @login="3vk59E5BgM"> 
    
    In production mode set :mode to 'production' and pass your production key and login
    
    report = AuthorizeNetReporting::Report.new({ :mode => 'production', :key => 'your_production_api_key', :login => 'your_production_api_login' })  
    

**Retrieve Settled Batches within a date range**


    #It will default to the last 12 hours if no date range is provided
    ~$ batches = report.settled_batch_list({ :first_settlement_date => "2011/04/20", :last_settlement_date => "2011/05/20"})
    
    #It will return an array of batches
    [
        [0] #<AuthorizeNetReporting::Batch:0x007fc099a08488 @batch_id="1033266", @settlement_time_utc="2011-04-21T05:17:52Z", @settlement_time_local="2011-04-21T00:17:52", @settlement_state="settledSuccessfully", @payment_method="creditCard">,
        [1] #<AuthorizeNetReporting::Batch:0x007fc099a07010 @batch_id="1039515", @settlement_time_utc="2011-04-26T05:17:34Z", @settlement_time_local="2011-04-26T00:17:34", @settlement_state="settledSuccessfully", @payment_method="creditCard">,
        [2] #<AuthorizeNetReporting::Batch:0x007fc099a061d8 @batch_id="1049686", @settlement_time_utc="2011-05-03T05:13:09Z", @settlement_time_local="2011-05-03T00:13:09", @settlement_state="settledSuccessfully", @payment_method="creditCard">,
        [3] #<AuthorizeNetReporting::Batch:0x007fc099a05210 @batch_id="1075905", @settlement_time_utc="2011-05-20T05:13:57Z", @settlement_time_local="2011-05-20T00:13:57", @settlement_state="settledSuccessfully", @payment_method="creditCard">
    ]

    
**Include statistics for each batch **

If you pass :include_statistics => true to the settled_batch_list resquest you will also receive batch statistics by payment type
     ~$ batches = report.settled_batch_list({ :first_settlement_date => "2011/04/20", :last_settlement_date => "2011/05/20", :include_statistics => true})
    
    #Result
    ~ $ batches.first 
    => #<AuthorizeNetReporting::Batch:0x007fd94b271f38 
        @batch_id="1033266", 
        @settlement_time_utc="2011-04-21T05:17:52Z", 
        @settlement_time_local="2011-04-21T00:17:52", 
        @settlement_state="settledSuccessfully", 
        @payment_method="creditCard", 
        @statistics=[ { :account_type=>"Visa", 
                        :charge_amount=>"14526.00", 
                        :charge_count=>"1", 
                        :refund_amount=>"0.00", 
                        :refund_count=>"0", 
                        :void_count=>"0", 
                        :decline_count=>"0", 
                        :error_count=>"0" } ]>
    
    

**Retrieve information for a specified Batch ID**

    ~$ batch = report.batch_statistics(1049686)
    
    => #<AuthorizeNetReporting::Batch:0x007fdb83966048 @batch_id="1049686", 
          @settlement_time_utc="2011-05-03T05:13:09Z", 
          @settlement_time_local="2011-05-03T00:13:09", 
          @settlement_state="settledSuccessfully", 
          @payment_method="creditCard", 
          @statistics=[ { :account_type=>"AmericanExpress", 
                          :charge_amount=>"1.00", 
                          :charge_count=>"1", 
                          :refund_amount=>"0.00", 
                          :refund_count=>"0", 
                          :void_count=>"0", 
                          :decline_count=>"0", 
                          :error_count=>"0" }, 
                        { :account_type=>"Visa", 
                          :charge_amount=>"899.52", 
                          :charge_count=>"3", 
                          :refund_amount=>"0.00", 
                          :refund_count=>"0", 
                          :void_count=>"0", 
                          :decline_count=>"0", 
                          :error_count=>"0" } ] >

**Retrieve Transaction details for a specified Batch ID**

    ~$ report.transaction_list(1049686)
    
    # Result
    
    [
      [1] #<AuthorizeNetReporting::AuthorizeNetTransaction:0x007fc3c392f8e0 @trans_id="2159639081", @submit_time_utc="2011-05-02T18:11:50Z", @submit_time_local="2011-05-02T13:11:50", @transaction_status="settledSuccessfully", @first_name="Max", @last_name="Schroeder", @account_type="Visa", @account_number="XXXX8888", @settle_amount="299.84">,
      [2] #<AuthorizeNetReporting::AuthorizeNetTransaction:0x007fc3c392bf10 @trans_id="2159639020", @submit_time_utc="2011-05-02T18:08:10Z", @submit_time_local="2011-05-02T13:08:10", @transaction_status="settledSuccessfully", @first_name="American", @last_name="Express", @account_type="AmericanExpress", @account_number="XXXX0002", @settle_amount="1.00">
    ]

**Retrieve Transaction Details for Unsettled Transactions**

Retrieve up to 1000 of the most recent transactions

    ~$ report.unsettled_transaction_list
    
    => [#<AuthorizeNetReporting::AuthorizeNetTransaction:0x007fc3c38b9960 @trans_id="2157217187", @submit_time_utc="2011-01-28T16:30:57Z", @submit_time_local="2011-01-28T10:30:57", @transaction_status="authorizedPendingCapture", @account_type="Visa", @account_number="XXXX0027", @settle_amount="25.45">] 


**Retrieve Detailed information about one specific transaction**


    ~$ report.transaction_details(2157585857)
    
    => #<AuthorizeNetReporting::AuthorizeNetTransaction:0x007fc3c2883668 
        @trans_id="2157585857", 
        @submit_time_utc="2011-02-16T21:51:10.953Z", 
        @submit_time_local="2011-02-16T15:51:10.953", 
        @transaction_status="settledSuccessfully", 
        @settle_amount="50.23", 
        @transaction_type="authCaptureTransaction", 
        @response_code="1", 
        @response_reason_code="1", 
        @response_reason_description="Approval",
        @auth_code="S1ZRPA", 
        @avs_response="Y", 
        @auth_amount="50.23", 
        @tax_exempt="false", 
        @recurring_billing="false"> 

** Debug **

To view the response from the API directly set debug to true
    ~$ report.debug = true
    ~$ report.transaction_details(2157585857)
    
  
# Copyright/License:

(The MIT License)

Copyright (c) 2011:

[Jazmin Schroeder](http://jazminschroeder.com)


