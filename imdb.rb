require 'nokogiri'
require 'open-uri'

class Imdb 
  def initialize(link)
    @main_page = link
    @movie_links_hash = Hash.new
    @movie_cast_hash = Hash.new
  end

  attr_reader :main_page
  attr_accessor :movie_links_hash
  attr_accessor :movie_cast_hash

  def html_parse_with_xpath(url,path)
    Nokogiri::HTML.parse(open(url)).xpath(path)
  end

  def get_rank_range(rank_range)
    rank_arr = rank_range.split(":").collect { |m| m.to_i }
    rank_arr.push(1) until rank_arr.length == 2
    rank_arr.pop until rank_arr.length == 2
    rank_arr.sort!
    rank_arr = rank_arr.map { |r| r <= 0 ? 1 : r }
    rank_arr
  end

  def populate_link_hash
    top_250_line = html_parse_with_xpath(main_page,"//div[@id='navbar']/div/ul/li/ul/li/a").detect do |tagline| 
      tagline.content == "Top 250" 
    end

    top_250_link = main_page + top_250_line['href']

    rank_range = gets_with_message "Enter range of rank"

    min_rank, max_rank = get_rank_range(rank_range)

    min_rank -= 1
    curr_rank = min_rank
    html_parse_with_xpath(top_250_link,"//table[2]/tr/td/font/a")[min_rank...max_rank].each do |elem| 
      @movie_links_hash[curr_rank] = [elem.content,elem['href']]
      curr_rank += 1
    end
  end

  def populate_cast_hash
    @movie_links_hash.each do |k,v|
      cast_page = @main_page + v[1] + "fullcredits?ref_=tt_cl_sm#cast"
      cast_list = []
      html_parse_with_xpath(cast_page,"//table[@class='cast']/tr/td[@class='nm']/a").each do |cast_link| 
        cast_list.push(cast_link.content)
      end
      @movie_links_hash[k] = v[0] # changing movie_links hash to Rank => Movie
      @movie_cast_hash[k] = cast_list
    end
  end

  def menu_option_m
    mov = gets_with_message "Exact name of Movie"
    rank = @movie_links_hash.key(mov)
    if rank 
      puts_movie_details(rank,mov)
    else 
      puts "Movie with this name doesnt exist!"
    end 
    true
  end

  def menu_option_r
    rank = gets_with_message "Enter rank of movie"
    rank = rank.to_i
    rank -= 1
    if @movie_links_hash.has_key?(rank) 
      movie = @movie_links_hash[rank]
      puts_movie_details(rank,movie)
    else 
      puts "Movie with this rank doesnt exist"
    end 
    true
  end
  
  def menu_option_c
    cast = gets_with_message "Enter name of cast member"
    worked = false

    output = "\t#{cast} has worked in: \n"
    @movie_cast_hash.each do |k,v|
      if v.include?(cast)
        output += "\t" + @movie_links_hash[k] 
        worked = true
      end
    end 
    puts output
    STDOUT.puts "Nothing!" unless worked
    true
  end
  
  def menu_option_x
    puts "Goodbye!"
    false
  end

  def puts_movie_details(rank, movie)
    puts "\tThe movie #{movie} has rank: #{rank+1}"
    output = "\tThe cast members are as follows: \n"
    @movie_cast_hash[rank].each { |cast_member| output += "\t" + cast_member }
    puts output
  end

  def gets_with_message(message)
    print message + " > "
    gets.chomp
  end
end
