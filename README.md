# WORK IN PROGRESS!!!! 
# AuhtorizeNetReporting

AuthorizeNetReporting allows you to retrieve Authorize.net transaction details through the [Transaction Details API](http://developer.authorize.net/api/transaction_details/)

# Sample Usage
**Go to [Authorize.net](http://authorize.net) to obtain your key/login**

````ruby
require 'rubygems'

require 'authorize_net_reporting'

report = AuthorizeNetReporting::Report.new({ :mode => ['test'|'live'], :key => 'your_api_key', :login => 'your_api_login' })  
````

**All settled batched with a date range**


````ruby
    #It will default to the last 12 hours if no date range is provided
    report.settled_batch_list({ :first_settlement_date => "2011/04/20", :last_settlement_date => "2011/05/20", :include_statistics => true })
````

**Statistics for a specific batch**

````ruby
    report.batch_statistics(1049686)
````

**Data for all transactions in a specified batch**

````ruby
    report.transaction_list(1049686)
````

**Unsettled Transactions**

````ruby
    report.unsettled_transaction_list
````

**Detailed information about one specific transaction**

    report.transaction_details(2157585857)
  
== LICENSE:

(The MIT License)

Copyright (c) 2011:

* {Jazmin Schroeder}[http://jazminschroeder.com]

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sub license, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
