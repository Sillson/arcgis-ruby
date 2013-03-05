require 'helper'

describe Arcgis::Sharing::Item do
  context "adding an item" do 
    before :all do
      @online = Arcgis::Online.new(:host => ArcConfig.config["online"]["host"])
      @username = ArcConfig.config["online"]["username"]
      @online.login(:username => @username, :password => ArcConfig.config["online"]["password"])
    end
    describe "by file" do
      before :all do
        @response = @online.add_item(
                         :title => "Gas Data",
                         :type => "CSV",
                         :file => File.open(File.dirname(__FILE__) + "/../data/gas_data.csv"),
                         :tags  => %w{test gas}.join(","))
        @id = @response["id"]        
        @analyze_response = @online.analyze_item(:id => @id, :type => "CSV")
        @item = @online.item(:id => @id)
      end
      context "with analysis" do
        it "should have publishParameters" do
          expect(@analyze_response["publishParameters"]["type"]).to eq("csv")
        end
        it "should have fields" do
          expect(@analyze_response["publishParameters"]["layerInfo"]["fields"].length).to eq(6)
        end
        describe "publishing" do 
          before :all do
            @publish_response = @online.publish_item(:id => @id,
              :filetype => "Feature Service",
              :publishParameters => @analyze_response["publishParameters"].to_json)
          end
          it "should be successful" do
            # puts "publish: #{@publish_response}"
            expect(@publish_response.include?("services")).to eq(true)
          end
          it "should have a serviceUrl" do
            expect(@publish_response["services"].first["serviceurl"].nil?).to eq(false)
          end
        end
      end
      
      it "should be an item" do
        expect(@item["id"]).to eq(@id)
      end
      it "should have tags" do
        expect(@item["tags"]).to eq(%w{test gas})
      end
      it "should have title" do
        expect(@item["title"]).to eq("Gas Data")
      end
      it "should have type" do
        expect(@item["type"]).to eq("CSV")
      end
      it "should have description" do
        expect(@item["description"]).to eq(nil)
      end
      it "should have blank rating" do
        expect(@item["avgRating"]).to eq(0)
      end        
      it "should have no ratings" do
        expect(@item["numRatings"]).to eq(0)
      end        
      it "should have no comments" do
        expect(@item["numComments"]).to eq(0)
      end
      it "should have owner" do
        expect(@item["owner"]).to eq(@username)
      end
      after :all do
        response = @online.delete_items(:items => [@item["id"]])
        expect(response["results"].first["success"]).to eq(true)
      end
    end
  end
end
