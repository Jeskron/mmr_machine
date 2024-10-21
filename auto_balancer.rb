#Return an array consisting of two arrays with balanced player objects
def auto_balancer ( players )

    #Sort the players by mmr value desc
    sorted_players = players.sort_by { |player| player.mmr }.reverse 
    
    #Establish holders and tracker
    team_one = []
    team_two = []
    
    #Teams get a Higher valued player if they are lower mmr and count, vice versa
    while sorted_players.count > 0
        if average_mmr( team_one ) <= average_mmr( team_two )
            if team_one.count > team_two.count
                team_two << sorted_players.pop
            else
                team_one << sorted_players.shift
            end
        else
            if team_two.count > team_one.count
                team_one << sorted_players.pop
            else
                team_two << sorted_players.shift
            end
        end
    end

    return teams = [ team_one, team_two ]    
end

#Helper method for average mmr calculation
def average_mmr( team )
    if team.count == 0
        return 0
    else
    player_count = 0
    avg_sum = 0

    team.each do |player|
        player_count += 1
        avg_sum += player.mmr
    end
    return average = avg_sum / player_count
end
end