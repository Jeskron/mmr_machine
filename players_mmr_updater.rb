def players_mmr_updater( players, opp_mmr, result, master_db, list_store_db )

    players.each do |player|
            player.mmr = mmr_adjuster( player.mmr, opp_mmr, result )
            master_db.each do |db_player|
                if db_player.name == player.name
                    db_player.mmr = player.mmr
                end
            end   
    end 
    update_tree_view( list_store_db, master_db )                       
end