require_relative "../spec_helper"

describe DigitalOcean do
  describe "::Auth" do
    it "loads client_id from auth file" do
      DigitalOcean::Auth::CLIENT_ID.should_not be(nil)
    end
    it "loads api_key from auth file" do
      DigitalOcean::Auth::API_KEY.should_not be(nil)
    end
  end
end
