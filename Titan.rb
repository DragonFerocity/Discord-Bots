require 'discordrb'
require 'open-uri'
require 'net/https'

$usedLetters = Array.new
bot = Discordrb::Commands::CommandBot.new token: 'MjQ1Mjg4MTU5MDAzNDEwNDMz.CwJ6bA.I07_4YjdQ9isJ_jhyIBS8-wPNBQ', client_id: 245288159003410433, prefix: '!'

puts "This is the invite token #{bot.invite_url}."

#Testing Only
  bot.command :chinfo do |m|
    $chname = m.channel.name
    $chid = m.channel.id
    $chtopic = m.channel.topic
    $chtype = m.channel.type
    $chpos = m.channel.position
    $chserver = m.channel.server
    m.respond "**Channel Name**: #{$chname}\n**Channel ID**: #{$chid}\n**Channel Topic**: #{$chtopic}\n**Channel Type**: #{$chtype}\n**Channel Position**: #{$chpos}\n**Channel Server**: #{$chserver}"
    puts "\n\n"
    puts m.message.inspect
    puts "\n\n"
    puts m.channel.inspect
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

#Search Techradar
  bot.command :techradar do |m, article, *word|
    $search_word = word.to_a.join("+");
    string = ""
    endArticle = article
    if (article =~ /(\d)\-(\d)/)
      article = $1.to_i
      endArticle = $2.to_i
    end
    $url = "http://www.techradar.com/search?searchTerm=#{$search_word}"
    begin
      if (article < endArticle)
        while article <= endArticle
          $source = open($url).read
          $source =~ /<div class="listingResults" data-sort="page">.*/m
          $source.match(/<div class=\"listingResult small result#{article} \" data-page=\"1\">[\n\r]<a href="(.*)">/)
          $def = $1
          string <<  "#{article}. " << $def << "\n"
          article = article+1
        end
      else
        $source = open($url).read
        $source =~ /<div class="listingResults" data-sort="page">.*/m
        $source.match(/<div class=\"listingResult small result#{article} \" data-page=\"1\">[\n\r]<a href="(.*)">/)
        $def = $1
        string <<  "#{article}. " << $def << "\n"
      end
     rescue
        $search_word.gsub!(/\+/, " ")
        string << "I can't seem to find an article for \"#{$search_word}\"!"
     end
     m.respond string
  end
#Return GW2 Wiki Article
  bot.command :gw2 do |m, *item|
    $items = item.to_a
    for i in 0..$items.length-1
      $items[i] = $items[i].to_s.downcase
      if (i == 0)
        $items[i].capitalize!
      elsif ($items[i] != "and" && $items[i] != "or" && $items[i] != "the" && $items[i] != "a" && $items[i] != "in")
        $items[i].capitalize!
      else
        $items[i].downcase!
      end
    end
    $search_word = $items.join("_");
    $url = "https://wiki.guildwars2.com/wiki/#{$search_word}"
    #$source = open($url).read
    #if (/There is currently no text in this page\./m =~ $source)
    #  m.respond "The \"#{$items}\" page doesn't exist!"
    #else
      m.respond $url
    #end
  end
#Cointoss
  bot.command :coinflip do |m|
      if (rand(2) == 0)
          m.respond "Heads!"
      else
          m.respond "Tails!"
      end
  end

#Game Picker
  bot.command :play do |m|
    $games = Hash.new
    File.open("games.txt", "r") do |f|
      f.each_line do |line|
        $games[line] = 0
      end
    end

    srand Time.now.to_i
    $gameNames = $games.keys
    $numGames = $gameNames.length
    $pickedNum = -1
    $selectedGame = ""
    $numIterations = 2000000

    def threadedSub(hash, numGames, gameNames)
      for i in 0..1000000
        randN = rand(numGames)
        hash[gameNames[randN]] += 1
      end
      return hash
    end

    thread1 = Thread.new{threadedSub($games, $numGames, $gameNames)}
    thread2 = Thread.new{threadedSub($games, $numGames, $gameNames)}
    thread3 = Thread.new{threadedSub($games, $numGames, $gameNames)}

    hash1 = thread1.value
    hash2 = thread2.value
    hash3 = thread2.value

    for i in 0..$numGames
      $games[$gameNames[i]] = hash1[$gameNames[i]].to_i + hash2[$gameNames[i]].to_i + hash3[$gameNames[i]].to_i
    end

    for i in 0..$numGames
      if ($pickedNum < $games[$gameNames[i]])
        $pickedNum = $games[$gameNames[i]]
        $selectedGame = i
      end
    end

    sortedHash = $games.sort_by {|_key, value| value}.to_a.reverse.to_h
    hashKeys = sortedHash.keys.to_a
    range = sortedHash[hashKeys[0]] - sortedHash[hashKeys[$numGames-1]]
    $gamesToShow = ($numGames/3).floor
    lowestPercent = (sortedHash[hashKeys[$gamesToShow*2]] - sortedHash[hashKeys[$gamesToShow*2+1]])/range.to_f
    string = ""

    for k in 0..$gamesToShow-1
      string << "#{k+1}. #{hashKeys[k].chomp} (#{( ((sortedHash[hashKeys[k]] - sortedHash[hashKeys[$gamesToShow*2+1]])/range.to_f - lowestPercent)*100 ).floor}%)\n"
    end
    m.respond string
  end

#Game Adder
  bot.command :addgame do |m, *words|
    if (words.to_a.length > 0)
      $game = words.to_a.map(&:capitalize).join(" ");
      File.open("games.txt", "a") do |f|
        f << "\n#{$game}"
      end
      m.respond "#{$game} added to list!"
    else
      m.respond "You must specify a game to add #{m.user.nick}!"
    end
  end

#Game Lister
  bot.command :listgames do |m|
    $string = ""
    $k = 0
    File.open("games.txt", "r") do |f|
      f.each_line do |line|
        $string << "#{$k+1}. #{line}"
        $k += 1
      end
    end
    m.respond $string
  end

#Game Remover
  bot.command :rmgame do |m, int|
    if (int.to_i > 0)
      $k = 0
      $arr = Array.new
      File.open("games.txt", "r") do |f|
        f.each_line do |line|
          $arr[$k] = line.chomp
          $k += 1
        end
      end
      if (int.to_i <= $arr.length)
        $rm = $arr[int.to_i-1].to_s.capitalize
        $arr.delete_at(int.to_i-1)
        $str = $arr.join("\n").strip
        File.open("games.txt", "w") do |f|
          f << $str
        end
        m.respond "#{$rm} removed!"
      else
        m.respond "I can't remove an item that doesn't exist #{m.user.nick}!"
      end
    else
      m.respond "I can't remove a negative item #{m.user.nick}!"
    end
  end

#Random Number
bot.command :rand do |m, *nums|
  range = nums.to_a
    if (range.length == 1 && range[0].to_i == 0)
      m.respond "#{m.user.nick.to_s.upcase} YOU FOOL!"
    elsif (range.length == 1)
      if (range[0].to_i < 0)
        m.respond "-" + rand(range[0].to_i).to_s
      elsif
        m.respond rand(range[0].to_i)
      end
    elsif (range.length == 2)
      if (range[0].to_i < range[1].to_i)
        m.respond rand(range[1].to_i - range[0].to_i) + range[0].to_i
      else
        m.respond "I can't use a negative range, #{m.user.nick.to_s.upcase}!"
      end
    elsif (range.length == 3)
      if (range[0].to_i < range[1].to_i)
        randNum = rand(range[1].to_i - range[0].to_i) + range[0].to_i
        m.respond (randNum - randNum % range[2].to_i)
      else
        m.respond "I can't use a negative range, #{m.user.nick}!"
      end
    else
      m.respond "You must give me a number, #{m.user.nick}!"
    end
end

#Burn Giver
  bot.command :burn do |m, user|
    $games = Array.new
    File.open("burns.txt", "r") do |f|
      f.each_line do |line|
        $games.push(line.rstrip)
      end
    end
    $rand = rand($games.length)
    m.respond "@#{user}: #{$games[$rand]}!"
  end

#Burn Adder
  bot.command :addburn do |m, *words|
    if (words.to_a.length > 0)
      $burn = words.to_a.map(&:capitalize).join(" ");
      File.open("burns.txt", "a") do |f|
        f << "\n#{$burn}"
      end
      m.respond "\"#{$burn}\" added to list!"
    else
      m.respond "You can't give me an empty burn #{m.user.nick}!"
    end
  end

#Random Number
  bot.command :titanhelp do |m|
      string = ""
      string << "1. !define [word] - Returns a link to the definition of the word specified on dictionary.com\n"
      string << "2. !coinflip - Returns heads or tails, randomly...\n"
      string << "4. !play - Randomly pickes a game from an array 1,000,000 times on 3 threads and then returns the top n/3 that were picked the most\n"
      string << "4a. !addgame [name] - Adds the given name to the list of games to pick from\n"
      string << "4b. !rmgame [num] - Removes the game at position num in the list of games from the list of games to pick from\n"
      string << "4c. !listgames - Lists the games that are possible to pick from\n"
      string << "5. !rand [number] - Returns a random number between 0 and the number specified. Works with ints only\n"
      string << "     !rand [start_of_range] [end_of_range] - Returns a random number in the range specified. Works with ints only\n"
      string << "     !rand [start_of_range] [end_of_range] [divisibility_factor] - Returns a random number in the range specified that is divisible by the divisibility_factor specified. Works with ints only\n"
      string << "6. !techradar [article_number_or_range] [search terms] - Searches techradar and returns a list of articles that match. Use 1 for only one article, and n-m for a range of articles\n"
      string << "7. !burn [user] - Responds with a burn to the specified user\n"
      m.respond string
  end

bot.run
