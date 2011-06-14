require 'spec_helper'
describe AuthorizeNetReporting do
  let(:test_mode) do
     #TEST API LOGIN: 3vk59E5BgM - API KEY:4c8FeAW7ebq5U733
    { :mode => "test", :login=>"3vk59E5BgM", :key => "4c8FeAW7ebq5U733" }
  end
  
  let(:live_mode) do
    { :mode => "live", :key=>"key", :login => "login" }
  end  
  context "missing requirements" do
    it "should raise exception" do
      lambda { AuthorizeNetReporting.new }.should raise_error(ArgumentError)
    end
  end
  
  describe "API URL in test mode" do 
    subject {AuthorizeNetReporting.new(test_mode)}
    it 'should be test url' do
      subject.api_url.should eql(AuthorizeNetReporting::TEST_URL)
    end
  end
  
  describe "API URL in live mode" do
    subject { AuthorizeNetReporting.new(live_mode) }
    it "should be live url" do
      subject.api_url.should eql(AuthorizeNetReporting::LIVE_URL)
    end
  end
  
  describe "transaction_details" do
    subject { AuthorizeNetReporting.new(test_mode) } 
    it "should return transaction if transaction_exists" do
      transaction = subject.transaction_details(2157585857)
      transaction.should be_an_instance_of(AuthorizeNetTransaction)
    end
    it "should raise StandardError 'record not found' if transaction doesn't exist" do
      lambda { subject.transaction_details(0) }.should raise_error(StandardError)
    end
  end
  
  describe "settled_batch_list" do
    subject { AuthorizeNetReporting.new(test_mode) }
    context "with no batches settled in the last 24 hours" do
      it "should raise Standard Error if no batches are found within the given range" do
        lambda { subject.settled_batch_list }.should raise_error(StandardError)
      end
    end
    context "when there are settled batches" do
      it "should return batches settled in the last 24 hours" do
       pending "TODO"
       subject.settled_batch_list
      end
      it "should return batches" do
        batches = subject.settled_batch_list({:first_settlement_date => "2011/04/20", :last_settlement_date => "2011/05/20"})
        batches.size.should eql(4)    
      end

    end
  end
  
end
