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

  describe "::Core" do
    it "auth_url should return correct string" do
      DigitalOcean::Core.auth_url.should_not be(nil)
    end

  end

  describe "::APIRoot" do
    # xit "should return the correct url" do
    #   VCR.use_cassette('api_docs') do
    #     DigitalOcean::APIRoot.display_docs.should eq(nil)
    #   end
    # end
  end

  describe "::Droplets" do
    # it "should show all droplets" do
    #   VCR.use_cassette('show_droplets') do
    #     DigitalOcean::Droplets.show_all[0].class.should eq(DigitalOcean::Droplet)
    #   end
    # end

    it "shows all droplets" do
      response = %Q|{"status":"OK","droplets":[{"backups_active":null,"id":100823,"image_id":420,"name":"test222","region_id":1,"size_id":33,"status":"active"}]}|
      stub_request(:get, %r{.*api.digitalocean.com/droplets/\?.*}).
        to_return(:body => "#{response}", :status => 200)

        DigitalOcean::Droplets.show_all[0].class.should eq(DigitalOcean::Droplet)
    end
    # it "shows detailed info on a droplet" do
    #   VCR.use_cassette('show_droplet') do
    #     DigitalOcean::Droplets.show(112728).class.should eq(DigitalOcean::Droplet)
    #   end
    # end

    it "shows detailed droplet info" do
      id = 100823
      response = %Q|{"status":"OK","droplet":{"backups_active":null,"id":100823,"image_id":420,"name":"test222","region_id":1,"size_id":33,"status":"active"}}|
      stub_request(:get, %r{.*api.digitalocean.com/droplets/100823\?.*}).
        to_return(:body => "#{response}", :status => 200)

        DigitalOcean::Droplets.show(id).class.should eq(DigitalOcean::Droplet)

    end

    describe "#new" do
      let(:name) { "test_name" }
      let(:size_id) { "32" }
      let(:image_id) { "419" }
      let(:region_id) { "test_region_id" }
      let(:ssh_keys_id) { "" }

      xit "creates a new droplet when all variables are present" do
        response = %Q|{"status":"OK","droplet":{"id":100824,"name":"test_name","image_id":419,"size_id":32,"event_id":7499}}|
        stub_request(:get, %r{https://api.digitalocean.com/droplets/new.*}).
          to_return(:body => "#{response}", :status => 200)

          DigitalOcean::Droplets.create(
            :name => name,
            :size_id => size_id,
            :image_id => image_id,
            :region_id => region_id
          )

      end
      it "creates a new droplet when required variables are present"
      it "fails with error when required variables are not present" do
        response = %Q|{"status":"OK","droplet":{"id":100824,"name":"test_name","image_id":419,"size_id":32,"event_id":7499}}|
        stub_request(:get, %r{https://api.digitalocean.com/droplets/new.*}).
          to_return(:body => "#{response}", :status => 200)

          lambda {
            DigitalOcean::Droplets.create(
              :size_id => size_id,
              :image_id => image_id,
              :region_id => region_id
            )
          }.should raise_exception(ArgumentError)
      end

    end

    # it "reboots when asked" do
    #   VCR.use_cassette('droplets_reboot') do
    #     r = DigitalOcean::Droplets.reboot(112728)['status'].should eq("OK")
    #   end
    # end

    it "reboots when asked" do
      response = %Q|{"status":"OK","event_id":7501}|
      stub_request(:get, %r{.*api.digitalocean.com/droplets/100823/reboot/\?.*}).
        to_return(:body => "#{response}", :status => 200)

    r = DigitalOcean::Droplets.reboot(100823)['status'].should eq("OK")
    end

    it "powercycles a droplet" do
      response = %Q|{"status":"OK","event_id":7501}|
      stub_request(:get, %r{.*api.digitalocean.com/droplets/100823/power_cycle/\?.*}).
        to_return(:body => "#{response}", :status => 200)

    r = DigitalOcean::Droplets.power_cycle(100823)['status'].should eq("OK")

    end

    %w[shutdown power_off power_on password_reset enable_backups disable_backups destroy].each do |command|
      it "#{command} a droplet" do

        response = %Q|{"status":"OK","event_id":7501}|
        stub_request(:get, %r{.*api.digitalocean.com/droplets/100823/#{command}/\?.*}).
          to_return(:body => "#{response}", :status => 200)

        DigitalOcean::Droplets.public_send(command, 100823)['status'].should eq("OK")

      end

    end
      it "takes a snapshot" do
        response = %Q|{"status":"OK","event_id":7501}|
        stub_http_request(:get, %r{.*api.digitalocean.com/droplets/100823/snapshot/\?.*}).
          with(:query => hash_including({"name" => "snap_name"})).
          to_return(:body => "#{response}", :status => 200)

        DigitalOcean::Droplets.public_send("snapshot", 100823, "snap_name" )['status'].should eq("OK")

      end
      it "resizes the droplet" do
        command = "resize"
        response = %Q|{"status":"OK","event_id":7501}|
        stub_http_request(:get, %r{.*api.digitalocean.com/droplets/100823/#{command}/\?.*}).
          with(:query => hash_including({"size_id" => "1123"})).
          to_return(:body => "#{response}", :status => 200)

        DigitalOcean::Droplets.public_send(command, 100823, 1123)['status'].should eq("OK")

      end
      it "restores the droplet" do
        command = "restore"
        response = %Q|{"status":"OK","event_id":7501}|
        stub_http_request(:get, %r{.*api.digitalocean.com/droplets/100823/#{command}/\?.*}).
          with(:query => hash_including({"image_id" => "1123"})).
          to_return(:body => "#{response}", :status => 200)

        DigitalOcean::Droplets.public_send(command, 100823, 1123)['status'].should eq("OK")

      end
      it "rebuilds the droplet" do
        command = "rebuild"
        response = %Q|{"status":"OK","event_id":7501}|
        stub_http_request(:get, %r{.*api.digitalocean.com/droplets/100823/#{command}/\?.*}).
          with(:query => hash_including({"image_id" => "1123"})).
          to_return(:body => "#{response}", :status => 200)

        DigitalOcean::Droplets.public_send(command, 100823, 1123)['status'].should eq("OK")

      end
  end
  describe "::Regions" do
    describe "#show_all" do
      it "returns region objects" do
        response = %Q|{"status":"OK","regions":[{"id":1,"name":"New York 1"},{"id":2,"name":"Amsterdam 1"}]}|
        stub_request(:get, %r{https://api.digitalocean.com/regions/}).
          to_return(:body => response, :status => 200)
        DigitalOcean::Regions.show_all.first.class.should eq(DigitalOcean::Region)
      end
    end
  end
end
