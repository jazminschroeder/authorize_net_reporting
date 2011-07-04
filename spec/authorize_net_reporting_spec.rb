require 'spec_helper'
describe AuthorizeNetReporting::Report do
  let(:test_mode) do
     #TEST API LOGIN: 3vk59E5BgM - API KEY:4c8FeAW7ebq5U733
    { :mode => "test", :login=>"3vk59E5BgM", :key => "4c8FeAW7ebq5U733" }
  end
  
  let(:live_mode) do
    { :mode => "live", :key=>"key", :login => "login" }
  end  
  context "missing requirements" do
    it "should raise exception" do
      lambda { AuthorizeNetReporting::Report.new }.should raise_error(ArgumentError)
    end
  end
  describe "API URL in live mode" do
    subject { AuthorizeNetReporting::Report.new(live_mode) }
    it "should be live url" do
      subject.api_url.should eql(AuthorizeNetReporting::Report::LIVE_URL)
    end
  end
  
  before(:each) do
    @authorize_net_reporting = AuthorizeNetReporting::Report.new(test_mode)
  end  
  
  describe "API URL in test mode" do 
    it 'should be test url' do
      @authorize_net_reporting.api_url.should eql(AuthorizeNetReporting::Report::TEST_URL)
    end
  end

  describe "settled_batch_list" do
    context "when there are not batches settled" do
      it "should return an empty array" do
        @authorize_net_reporting.settled_batch_list.should be_empty
      end
    end
    context "when there are settled batches" do
      it "should return batches" do
        batches = @authorize_net_reporting.settled_batch_list({:first_settlement_date => "2011/04/20", :last_settlement_date => "2011/05/20"})
        batches.size.should eql(4)    
      end
    end
    context "when request include statistics" do
      it "should return statistis as an Array" do 
        batches = @authorize_net_reporting.settled_batch_list({:first_settlement_date => "2011/04/20", :last_settlement_date => "2011/05/20", :include_statistics => true})
        batches.first.statistics.should be_an_instance_of(Array)
      end  
    end  
  end
  
  describe "batch_statistics" do
    it "should return an array statistics for given batch" do
      @authorize_net_reporting.batch_statistics(1049686).statistics.should be_an_instance_of(Array)
    end
  end
  
  describe "transactions_list" do
    it "should return all transactions in a specified batch" do
      transactions = @authorize_net_reporting.transaction_list(1049686)
      transactions.size.should eql(4)
    end
  end  

  describe "unsettled_transaction_list" do
    it "should return unsettled transactions" do
      transactions = @authorize_net_reporting.unsettled_transaction_list
      transactions.should be_an_instance_of(Array)
    end  
  end  
  
  describe "transaction_details" do
    it "should return transaction if transaction_exists" do
      transaction = @authorize_net_reporting.transaction_details(2157585857)
      transaction.should be_an_instance_of(AuthorizeNetReporting::AuthorizeNetTransaction)
    end
    it "should return nil if transaction doesn't exist" do
      @authorize_net_reporting.transaction_details(0).should be_nil
    end
  end
end
