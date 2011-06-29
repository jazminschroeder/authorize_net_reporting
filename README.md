# WORK IN PROGRESS!!!! 
# AuhtorizeNetReporting

AuthorizeNetReporting allows you to retrieve transaction details through the [Transaction Details API](http://developer.authorize.net/api/transaction_details/)

##Available Functions
__settled_batch_list__(*API: getSettledBatchListRequest*) 

This function returns information about a settled batch: Batch ID, Settlement Time, &
Settlement State.

__batch_statistics__(*API: getBatchStatisticsRequest*)

This function returns batch statistics for a single batch.

__transaction_list__(*API: getTransactionListRequest*)

This function returns transaction details for a specified batch ID.

__unsettled_transaction_list__(*API: getUnsettledTransactionListRequest*)

This function returns details for unsettled transactions

__transaction_details__(*API: getTransactionDetailsRequest*)

This function returns full transaction details for a specified transaction ID.  