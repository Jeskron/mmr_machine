#Used to adjust the mmr of a player depending on opp and result
def mmr_adjuster( player_score, opponent_score, result )

    #Adjusts the volatility of change
    k_factor = 10

    #Calculation for the ecpected result
    expected_score = 1 / ( 1 + 10**(( opponent_score - player_score )/ 400.0 ))

    #Main calculation and return of the updated score
    updated_score = player_score + k_factor * ( result - expected_score )
end