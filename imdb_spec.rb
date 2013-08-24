require './spec_helper'
require './imdb'
describe Imdb do
	before :each do
		@imdb = Imdb.new "http://www.imdb.com"
	end
	describe "#new" do
		it "returns instance" do
			@imdb.should be_an_instance_of Imdb
		end
		it "raises argument error for no arguments" do
			lambda { Imdb.new }.should raise_exception ArgumentError
		end
	end
	describe "#html_parse_with_xpath" do
		it "returns object of type xpath" do
			x = @imdb.html_parse_with_xpath(@imdb.main_page,"//a")
			x.should be_an_instance_of Nokogiri::XML::NodeSet
		end
	end
	describe "#get_rank_range" do
		it "returns a array with two integers, sorted, with a minimum value of 1" do
			x,y = @imdb.get_rank_range("-1:a")
			x.should be_an_instance_of Fixnum
			y.should be_an_instance_of Fixnum
			x.should be <= y
			x.should be >= 1
			y.should be >= 1
		end
	end
	describe "#populate_link_hash" do
		it "makes at least one entry in the link hash in the format rank => [name, path]" do
			@imdb.populate_link_hash
			h = @imdb.instance_variable_get(:@movie_links_hash)
			k,v = h.first
			k.should be_an_instance_of Fixnum
			v.should be_an_instance_of Array
			v.length.should be == 2
			v[0].should be_an_instance_of String
			v[1].should be_an_instance_of String
		end
	end
	describe "#populate_cast_hash" do
		it "makes at least one entry in the cast hash as rank => [member1,member2...]" do
			@imdb.populate_link_hash
			@imdb.populate_cast_hash
			h = @imdb.instance_variable_get(:@movie_cast_hash)
			k,v = h.first
			k.should be_an_instance_of Fixnum
			v.should be_an_instance_of Array
			v.each do |val| 
				val.should be_an_instance_of String
			end
		end
	end
	describe "#mrcx_menu" do
		before :each do
			@imdb.populate_link_hash
			@imdb.populate_cast_hash
		end

		it "raises argument error for no arguments" do
			lambda { @imdb.mrcx_menu }.should raise_exception ArgumentError
		end
		it "provides rank and cast-list for movie name when input is for option: 'm'" do
			STDIN.should_receive(:gets).and_return("The Shawshank Redemption")
			STDOUT.should_receive(:puts).with("\tThe movie The Shawshank Redemption has rank: 1")
			STDOUT.should_receive(:puts).with(/\s*\S*/	)
			@imdb.mrcx_menu('m').should be true		
		end
		it "prints error message when movie name is not there in list os for option: 'm'" do
			STDIN.should_receive(:gets).and_return("abcd")
			STDOUT.should_receive(:puts).with("Movie with this name doesnt exist!")
			@imdb.mrcx_menu('m').should be true
		end
		it "provides rank and cast-list for rank when input is 'r'" do
			STDIN.should_receive(:gets).and_return("1")
			STDOUT.should_receive(:puts).with("\tThe movie The Shawshank Redemption has rank: 1")
			STDOUT.should_receive(:puts).with(/\s*\S*/)
			@imdb.mrcx_menu('r').should be true		
		end
		it "provides rank and cast-list for rank when input is 'r'" do
			STDIN.should_receive(:gets).and_return("0")
			STDOUT.should_receive(:puts).with("Movie with this rank doesnt exist")
			@imdb.mrcx_menu('r').should be true	
		end
		it "provides rank and cast-list for rank when input is 'c'" do
			STDIN.should_receive(:gets).and_return("Tim Robbins")
			STDOUT.should_receive(:puts).with("\tTim Robbins has worked in: \n\tThe Shawshank Redemption")
			@imdb.mrcx_menu('c').should be true
		end
		it "returns false for option 'x'" do
			STDOUT.should_receive(:puts).with("Goodbye!")
			@imdb.mrcx_menu('x').should be false
		end
		it "asks for correct input if not among the options" do
			STDOUT.should_receive(:puts).with("Please enter either m, r, c or x as an input!")
			@imdb.mrcx_menu('a').should be true
		end
	end
	describe "#puts_movie_details" do
		it "raises ArgumentError for less than two arguments" do
			lambda { @imdb.puts_movie_details }.should raise_exception ArgumentError
		end
	end
end
