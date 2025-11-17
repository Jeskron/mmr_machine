#Serialises player object attributes into text. #name,#mmr
def save_playerdata( players_array )  
  players_array = players_array.flatten
  players_array = players_array.sort_by { |player| -player.mmr }
    # Open the file with "w" mode, which clears the file if it exists

    File.open("players.txt", "w") do |file|
      # Make a string of name and mmr and add to file
      players_array.each do |player|
        file.puts("#{player.name},#{player.mmr}")        
      end  
    end
    return players_array
  end

#Reintializes player objects with text data. #name,#mmr
def read_savedata( file_path )

    #Checks if file exists, makes file
    if !File.exist?( file_path )          
        return []
    end

    #Reads lines and adds as string to nestled array
    player_data = []
    File.foreach( file_path ) do |line|
        split_data = line.strip.split(",")
        player_data << split_data       
    end

    player_objects = player_data.map { |player| Player.new( player[0], player[1].to_f)}
end