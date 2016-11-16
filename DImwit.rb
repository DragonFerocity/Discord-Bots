require 'discordrb'
require 'open-uri'
require 'net/https'

$usedLetters = Array.new
bot = Discordrb::Commands::CommandBot.new token: 'MjE4MTAwOTgxMzk5ODE0MTQ0.Cp-UbA.cud9-k6XH_w0WLf9MpXEhMEbO0s', client_id: 218100981399814144, prefix: '!'

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
#Search Youtube
  bot.command :youtube do |m, article, *word|
    $search_word = word.to_a.join("+");
    string = ""
    endArticle = article
    if (article =~ /(\d)\-(\d)/)
      article = $1.to_i
      endArticle = $2.to_i
    end
    $url = "https://www.youtube.com/results?search_query=#{$search_word}"
    puts $url
    begin
      if (article < endArticle)
        while article <= endArticle
          $source = open($url).read
          $matches = $source.scan(/<a href="\/(watch\?v=.*)\" class/).flatten
          $def = $matches[article]
          string << "#{article}. " << "https://www.youtube.com/#{$def}" << "\n"
          article = article+1
        end
      else
        puts "A"
        #$source = open($url).read

        uri = URI('https://www.google.com/')

        Net::HTTP.start(uri.host, uri.port,
          :use_ssl => uri.scheme == 'https') do |http|
          request = Net::HTTP::Get.new uri

          response = http.request request # Net::HTTPResponse object
          puts response.body
        end

        #$source = URI.parse($url).read
        #$matches = $source.scan(/<a href="\/(watch\?v=.*)\" class/).flatten
        #puts $matches
        #$def = $matches[article]
        #string << "#{article}. " << "https://www.youtube.com/#{$def}" << "\n"
      end
    rescue
        $search_word.gsub!(/\+/, " ")
        string << "I can't seem to find a video for \"#{$search_word}\"!"
        puts $!
    end
    #m.respond string
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

#Restaraunt Picker
  bot.command :lunch do |m|
    restaurantHash = {
      "Tater Patch" => 0,
      "Lee's Chicken" => 0,
      "Colton's" => 0,
      "Panera" => 0,
      "Pizza Hut" => 0,
      "Randy's Roadkill" => 0,
      "Waffle House" => 0,
      "Subway" => 0,
      "Koi" => 0,
      "Los Cazadorres" => 0,
      "Sirloin Stockade" => 0,
      "Arby's" => 0,
      "Dairy Queen" => 0,
      "Lucky House" => 0,
      "Bandanna's" => 0,
      "O'Doggys" => 0,
      "Applebees" => 0,
      "El Maguey" => 0,
      "Taco Bell" => 0,
      "Hardee's" => 0,
      "Steak & Shake" => 0,
      "Buffalo Wild Wings" => 0,
      "Wendy's" => 0,
      "Imo's Pizza" => 0,
      "Alex's Pizza Kitchen" => 0,
    }

    srand Time.now.to_i
    restaurants = restaurantHash.keys
    numRestaurants = restaurants.length
    pickedNum = -1
    selectedRestaurant = ""
    numIterations = 2000000

    def threadedSub(hash, numRestaurants, restaurants)
      for i in 0..1000000
        randN = rand(numRestaurants)
        hash[restaurants[randN]] += 1
      end
      return hash
    end

    thread1 = Thread.new{threadedSub(restaurantHash, numRestaurants, restaurants)}
    thread2 = Thread.new{threadedSub(restaurantHash, numRestaurants, restaurants)}
    thread3 = Thread.new{threadedSub(restaurantHash, numRestaurants, restaurants)}

    hash1 = thread1.value
    hash2 = thread2.value
    hash3 = thread2.value

    for i in 0..numRestaurants
      restaurantHash[restaurants[i]] = hash1[restaurants[i]].to_i + hash2[restaurants[i]].to_i + hash3[restaurants[i]].to_i
    end

    for i in 0..numRestaurants
      if (pickedNum < restaurantHash[restaurants[i]])
        pickedNum = restaurantHash[restaurants[i]]
        selectedRestaurant = i
      end
    end

    sortedHash = restaurantHash.sort_by {|_key, value| value}.to_a.reverse.to_h
    hashKeys = sortedHash.keys.to_a
    range = sortedHash[hashKeys[0]] - sortedHash[hashKeys[6]]
    lowestPercent = (sortedHash[hashKeys[5]] - sortedHash[hashKeys[6]])/range.to_f
    string = ""

    for k in 0..4
      string << "#{k+1}. #{hashKeys[k]} (#{( ((sortedHash[hashKeys[k]] - sortedHash[hashKeys[6]])/range.to_f - lowestPercent)*100 ).floor}%)\n"
    end
    m.respond string
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
        m.respond "I can't use a negative range, #{m.user.nick.to_s.upcase} YOU FOOL!"
      end
    elsif (range.length == 3)
      if (range[0].to_i < range[1].to_i)
        randNum = rand(range[1].to_i - range[0].to_i) + range[0].to_i
        m.respond (randNum - randNum % range[2].to_i)
      else
        m.respond "I can't use a negative range, #{m.user.nick.to_s.upcase} YOU FOOL!"
      end
    else
      m.respond "You must give me a number, #{m.user.nick.to_s.upcase} YOU FOOL!"
    end
end

bot.command(:eval, help_available: false) do |event, *code|
  #break unless event.user.id == 000000 # Replace number with your ID

  begin
    eval code.join(' ')
  rescue
    "An error occured 😞"
  end
end

#Random Number
  bot.command :dimwithelp do |m|
      string = ""
      string << "1. !define [word] - Returns a link to the definition of the word specified on dictionary.com\n"
      string << "2. !coinflip - Returns heads or tails, randomly...\n"
      string << "3. !sonic - Returns a random sonic menu page\n"
      string << "4. !lunch - Randomly pickes a restaurant from an array 1,000,000 times on 3 threads and then returns the top 5 that were picked the most\n"
      string << "5. !rand [number] - Returns a random number between 0 and the number specified. Works with ints only\n"
      string << "     !rand [start_of_range] [end_of_range] - Returns a random number in the range specified. Works with ints only\n"
      string << "     !rand [start_of_range] [end_of_range] [divisibility_factor] - Returns a random number in the range specified that is divisible by the divisibility_factor specified. Works with ints only\n"
      string << "6. !techradar [article_number_or_range] [search terms] - Searches techradar and returns a list of articles that match. Use 1 for only one article, and n-m for a range of articles\n"
      m.respond string
  end

bot.run
