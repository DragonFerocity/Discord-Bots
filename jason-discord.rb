require 'discordrb'
require 'open-uri'

$game = 0
$phrase = ""
$modphrase = ""
$guesses = 6
$words = ""
$usedLetters = Array.new
bot = Discordrb::Commands::CommandBot.new token: 'MTc0OTk5OTEyOTI3MzMwMzA1.CgLE3g.GSuJFSFxHQqg-OE08vtfz8ppjJ8', application_id: 174999575268950017, prefix: '!'

puts "This is the invite token #{bot.invite_url}."
#bot.join "0ybCdfvF4UgDG0pI"
#respond "I'm back!"
#get user
  bot.command :aboutme do |m|
    m.respond "User: #{m.user.id}"
  end
#Define a word
  bot.command :define do |m, word|
    $search_word = word;
    if (word =~ /\s/)
      $search_word = word.gsub(/\s/, "%20")
    end
    $url = "http://www.dictionary.com/browse/#{$search_word}?s=t"
    begin
        $source = open($url).read
        #if (!$source =~ /.*There are no results.*/m)
        $source =~ /<span class="dbox-pg">(\w{4,9})<\/span>/
        $type = $1
        $source.match(/<div class="def-content">\s*(.*)<\/div>/)
        $def = $1
        $def.gsub!(/<.*?>/, "")
        if ($prev_word != $search_word)
           m.respond "#{$type.capitalize}: #{$def.capitalize} (#{$url})."
        else
           m.respond "I already defined \"#{word.capitalize}\" for you!"
        end
     rescue
        m.respond "I can't seem to find a definition for \"#{word}\"!"
     end
  end
#Get a bible verse
  bot.command :bible do |m, book, chapter, version|
    $ch = chapter
    $ch = $ch.gsub(/:.*/, "")
    #m.respond $ch
    $chapter = chapter
    if ($chapter =~ /:/)
      $chapter = $chapter.gsub(/:/, "%3A")
    end
    #m.respond chapter
    #m.respond $chapter
    $url = "https://www.biblegateway.com/passage/?search=#{book}+#{$chapter}&version=#{version}"
    m.respond $url
  end

#Tell a joke, add a Joke
    bot.command :joke do |m|
        $jokes = IO.readlines("jokes.txt")
        $jokeNum = $jokes[0].to_i
        $rand = rand($jokeNum) + 1
        m.respond $jokes[$rand]
    end
    bot.command :addjoke do |m, *joke|
        $joke = joke.join(" ")
        $jokes = IO.readlines("jokes.txt")
        $jokeNum = $jokes[0].to_i
        $jokes[0] = $jokeNum + 1
        $jokes.push($joke)
        $file = File.open("jokes.txt", "w+") do |f|
            f.puts($jokes)
        end
        m.respond "Added!"
    end
    bot.command :removejoke do |m, *joke|
        $joke = joke.join(" ")
        $num = $joke.length
        $jokes = IO.readlines("jokes.txt")
        $jokes.delete($joke + "\n")
        $jokeNum = $jokes[0].to_i
        $jokes[0] = $jokeNum - 1
        $file = File.open("jokes.txt", "w+") do |f|
            f.puts($jokes)
        end
        if ($joke.length == $num)
          m.respond "I couldn't find that joke to remove!"
        else
          m.respond "Removed!"
        end
    end
#Cointoss
    bot.command :coinflip do |m|
        if (rand(2) == 0)
            m.respond "Heads!"
        else
            m.respond "Tails!"
        end
    end

#Pick a sonic menu page
    bot.command :sonic do |m|
        $num = rand(22)
        case $num
        when 0
            m.respond "https://www.sonicdrivein.com/menu/146-burgers"
        when 1
            m.respond "https://www.sonicdrivein.com/menu/147-coneys-hot-dogs"
        when 2
            m.respond "https://www.sonicdrivein.com/menu/206-boneless-wings"
        when 3
            m.respond "https://www.sonicdrivein.com/menu/207-jumbo-popcorn-chicken-r"
        when 4
            m.respond "https://www.sonicdrivein.com/menu/208-chicken-sandwiches"
        when 5
            m.respond "https://www.sonicdrivein.com/menu/209-super-crunch-tm-chicken-strips"
        when 6
            m.respond "https://www.sonicdrivein.com/menu/152-breakfast"
        when 7
            m.respond "https://www.sonicdrivein.com/menu/168-snacks-sides"
        when 8
            m.respond "https://www.sonicdrivein.com/menu/192-candy-slushes"
        when 9
            m.respond "https://www.sonicdrivein.com/menu/159-real-fruit-slushes"
        when 10
            m.respond "https://www.sonicdrivein.com/menu/160-famous-slushes"
        when 11
            m.respond "https://www.sonicdrivein.com/menu/158-limeades"
        when 12
            m.respond "https://www.sonicdrivein.com/menu/153-soft-drinks"
        when 13
            m.respond "https://www.sonicdrivein.com/menu/188-ocean-water-r"
        when 14
            m.respond "https://www.sonicdrivein.com/menu/194-other"
        when 15
            m.respond "https://www.sonicdrivein.com/menu/201-master-shakes"
        when 16
            m.respond "https://www.sonicdrivein.com/menu/162-classic-shakes"
        when 17
            m.respond "https://www.sonicdrivein.com/menu/190-master-blasts-r"
        when 18
            m.respond "https://www.sonicdrivein.com/menu/161-sonic-blast-r"
        when 19
            m.respond "https://www.sonicdrivein.com/menu/166-waffle-cone-sundaes-cones"
        when 20
            m.respond "https://www.sonicdrivein.com/menu/205-molten-cake-sundaes"
        when 21
            m.respond "https://www.sonicdrivein.com/menu/165-real-ice-cream-sundaes"
        end
    end


#Join a channel
  bot.command :join do |m, invite|
    #if (m.user.id == 174982000703307776)
      m.bot.join invite
    #end
  end

bot.run
