require './imdb'

imdb = Imdb.new("http://www.imdb.com")

# Find min to max number of movies and store them in a movie_links_hash as Rank => [Name,Path] 
imdb.populate_link_hash

imdb.movie_links_hash.each { |k,v| puts "#{k+1}. #{v[0]}"}

# Populate the movie_cast_hash as Rank => Cast-List
imdb.populate_cast_hash


# Cast search
begin
  puts
  puts "---- Movie/Cast Listings ----"
  puts "'m' to view cast of a particular movie"
  puts "'r' to view cast of a particular movie"
  puts "'c' to search for all movies in the list earlier requested in which a cast member has performed "
  puts "'x' to exit"
  print "Your choice[m/r/c/x]? "
  choice = gets.chomp
  begin
    continue = imdb.send "menu_option_"+choice
  rescue NoMethodError => msg
    puts "Incorrect option entered!"
    continue = true
  end
end while continue