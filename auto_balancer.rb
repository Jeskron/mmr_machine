def auto_balancer( players )
    players_total_mmr = players.sum(&:mmr)
    ideal_team_mmr = players_total_mmr / 2.0
    subset_size = players.length / 2

    all_possible_teams = players.combination(subset_size).to_a

    team_one = all_possible_teams[0]
    best_difference = (total_mmr( team_one ) - ideal_team_mmr).abs

    all_possible_teams.each do |current_team|
        current_difference = (total_mmr( current_team ) - ideal_team_mmr).abs

        if current_difference < best_difference
            team_one = current_team
            best_difference = current_difference
        end
    end
    
    team_two = players - team_one
    return [ team_one, team_two]
end

def average_mmr(team)
  team.sum(&:mmr) / team.length.to_f
end

def total_mmr(team)
  team.sum(&:mmr)
end