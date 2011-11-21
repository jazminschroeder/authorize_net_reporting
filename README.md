# Authorize.Net Transaction Details  API 

In order to use the Transaction Details API you must have enabled Transaction Details API in the Merchant Interface account settings where you will find
your developer and production credentials. 

For more information about the API visit [Authorize.net Reporting API](http://developer.authorize.net/api/transaction_details/).

Note: You will be able to view test transactions at [https://sandbox.authorize.net](https://sandbox.authorize.net/).
 
# Installation
    # Gemfile
    
    gem 'authorize_net_reporting'
    

# Documentation
[Click here to view the Documentation](http://rubydoc.info/github/jazminschroeder/authorize_net_reporting/master/frames/)

# Usage example

Build a new AuthorizeNetReporting::Report object for test or production mode by passing your credentials as follows:

    ~$ require 'rubygems'
    ~$ require 'authorize_net_reporting'
    ~$ report = AuthorizeNetReporting::Report.new({ :mode => 'test', :key => 'your_developer_api_key', :login => 'your_developer_api_login' })   
    => #<AuthorizeNetReporting::Report:0x007fd94b2dd7b0 @mode="test", @key="XXXXXXX", @login="XXXXX"> 
    
    # In Production Mode
    ~$ report = AuthorizeNetReporting::Report.new({ :mode => 'production', :key => 'your_production_api_key', :login => 'your_production_api_login' })  
    => #<AuthorizeNetReporting::Report:0x007fd94b2dd7b0 @mode="production", @key="XXXXXXX", @login="XXXXX"> 

**Retrieve Settled Batches within a date range**

*Note: If no dates are specified, then the default is the last 24 hours.*
   
    ~$ batches = report.settled_batch_list({ :first_settlement_date => "2011/04/20", :last_settlement_date => "2011/05/20"})
    
    # Result
    [
		    [0] #<AuthorizeNetReporting::Batch:0x007ffbf3a03150 @batch_id="1364896", @settlement_time_utc="2011-11-19T06:21:10Z", @settlement_time_local="2011-11-19T00:21:10", @settlement_state="settledSuccessfully", @payment_method="creditCard">
		]

    
**Include statistics for each batch**

If you pass *:include_statistics => true* to the settled_batch_list resquest you will also receive batch statistics by payment type.
    
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
      [2] #<AuthorizeNetReporting::AuthorizeNetTransaction:0x007fc3c392bf10 @trans_id="2159639020", @submit_time_utc="2011-05-02T18:08:10Z", @submit_time_local="2011-05-02T13:08:10", @transaction_status="settledSuccessfully", @first_name="John", @last_name="Smith", @account_type="AmericanExpress", @account_number="XXXX0002", @settle_amount="1.00">
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

**Debug**

To view the response from the API directly set debug to true
    
    ~$ report.debug = true
    ~$ report.transaction_details(2157585857)
    

#Notes:

Tested with Ruby 1.8.7 and 1.9.2

# Copyright/License:

(The MIT License)

Copyright (c) 2011:

[Jazmin Schroeder](http://jazminschroeder.com)


