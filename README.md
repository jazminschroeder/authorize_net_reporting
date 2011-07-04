# WORK IN PROGRESS!!!! 
# AuhtorizeNetReporting

AuthorizeNetReporting allows you to retrieve Authorize.net transaction details through the [Transaction Details API](http://developer.authorize.net/api/transaction_details/)

# Sample Usage
**Go to [Authorize.net](http://authorize.net) to obtain your key/login**
````
require 'rubygems'

require 'authorize_net_reporting'


$ report = AuthorizeNetReporting::Report.new({ :mode => ['test'|'live'], :key => 'your_api_key', :login => 'your_api_login' })  
````
### All settled batched with a date range


$ report.settled_batch_list({ :first_settlement_date => "2011/04/20", :last_settlement_date => "2011/05/20", :include_statistics => true })


###Statistics for a specific batch

$ report.batch_statistics(1049686)


###Data for all transactions in a specified batch

$ report.transaction_list(1049686)


###Unsettled Transactions

$ report.unsettled_transaction_list


###Detailed information about one specific transaction

$ report.transaction_details(2157585857)
  
