require 'gtk3'

load './database.rb'
load './mmr_adjuster.rb'
load './player.rb'
load './auto_balancer.rb'
load './players_mmr_updater.rb' 

db_players_array = read_savedata( "players.txt" )
comp_players_array = []

#Window Settings
window = Gtk::Window.new("MMR Machine, by The Gooper")
window.set_size_request(900, 400)
window.set_border_width(10)

#Containers
main_box = Gtk::Box.new( :vertical, 10 )
sub_boxes = [
lists_box = Gtk::Box.new( :horizontal, 5 ),
controls_box = Gtk::Box.new( :horizontal, 2 )
]
db_list_store = Gtk::ListStore.new( String, Float )
comp_list_store = Gtk::ListStore.new( String, Float )

#Content
database_tree = Gtk::TreeView.new( db_list_store )
competing_tree = Gtk::TreeView.new( comp_list_store )
renderer = Gtk::CellRendererText.new

db_columns = [
db_player_column = Gtk::TreeViewColumn.new( "Player", 
renderer, text: 0 ),
db_mmr_column = Gtk::TreeViewColumn.new( "MMR", 
renderer, text: 1 )
]
comp_columns = [
comp_player_column = Gtk::TreeViewColumn.new( "Player", 
renderer, text: 0 ),
comp_mmr_column = Gtk::TreeViewColumn.new( "MMR", 
renderer, text: 1 )
]

database_list = Gtk::ScrolledWindow.new
competing_list = Gtk::ScrolledWindow.new
lists_box_buttons_content = [
left_arrow_button = Gtk::Button.new(:label => "<"),
balance_teams_button = Gtk::Button.new(:label => "Balance Teams"),
right_arrow_button = Gtk::Button.new(:label => ">")

]
controls_content = [
add_player_button = Gtk::Button.new(:label => "Add Player"),
remove_player_button = Gtk::Button.new(:label => "Remove Player"),
save_data_button = Gtk::Button.new(:label => "Save Data"),
reset_database_button = Gtk::Button.new(:label => "Reset Database"),
print_rankings_button = Gtk::Button.new(:label => "Print Rankings")
]

database_list.add( database_tree )
competing_list.add( competing_tree )

#Content Building
database_list.set_size_request(500, 800)
competing_list.set_size_request(500, 800)
window.add( main_box )
sub_boxes.each do |box|
    main_box.add( box )
end

#list_box building..annoying

lists_box.pack_start( database_list, expand: true, 
fill: true, padding: 5 )
lists_box_buttons_content.each do |widget|
    lists_box.pack_start( widget, expand: false, 
    fill: false, padding: 5 )
end
lists_box.pack_start( competing_list, expand: true, 
fill: true, padding: 5 )

controls_content.each do |widget|
    controls_box.pack_start( widget, expand: true, 
    fill: true, padding: 5 )
end

db_columns.each do |column|
    database_tree.append_column( column )
end

comp_columns.each do |column|
    competing_tree.append_column( column )
end

#Event Handling
add_player_button.signal_connect "clicked" do |_widget|
    #Window settings
    add_player_window = Gtk::Window.new("Add a player to database")
    add_player_window.set_size_request(350, 50)
    add_player_window.set_border_width(5)  
    #Widget settings
    add_player_box = Gtk::Box.new( :horizontal, 2 )
    add_player_buffer = Gtk::EntryBuffer.new( "Type player name..." )  
    add_player_widgets = [    
    add_player_input = Gtk::Entry.new( add_player_buffer ),
    add_button = Gtk::Button.new(label: "Add")     
    ]
    #Building
    add_player_widgets.each do |widget|
        add_player_box.pack_start( widget, expand: true, 
        fill: true, padding: 5 )
    end
    #Runtime
    add_player_window.add( add_player_box )  
    add_player_window.show_all
    #Definitions
    add_button.signal_connect "clicked" do |_widget|
        db_players_array.push( Player.new( 
            add_player_input.text, 1500 ) )
        update_tree_view( db_list_store, db_players_array )
        add_player_window.close
    end    
end

remove_player_button.signal_connect "clicked" do |_widget|
    selection = database_tree.selection
    iter = selection.selected
    next unless iter
    db_players_array.reject!{ |player| player.name == iter[0] }
    update_tree_view( db_list_store, db_players_array )
end
save_data_button.signal_connect "clicked" do |_widget|
    db_players_array = save_playerdata( db_players_array )
end
reset_database_button.signal_connect "clicked" do |_widget|
    db_players_array.clear
    update_tree_view( db_list_store, db_players_array )
end

print_rankings_button.signal_connect "clicked" do |_widget|    
    puts "MMR rankings:"
    text = "MMR rankings:\n"
    db_players_array.each do |player|        
        player_rank_string = "#{player.name}-#{'%.2f' % player.mmr}"
        puts player_rank_string
        text << "#{player_rank_string}\n"
    end

    Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD).set_text(text)
end

left_arrow_button.signal_connect "clicked" do |_widget|
    selection = competing_tree.selection
    iter = selection.selected
    next unless iter
    comp_players_array.reject! { |player| player.name == iter[0] }
    update_tree_view( comp_list_store, comp_players_array )
end

right_arrow_button.signal_connect "clicked" do |_widget|
    selection = database_tree.selection
    iter = selection.selected  
    next unless iter 
    comp_players_array.push( Player.new( iter[0], iter[1] ) )
    update_tree_view( comp_list_store, comp_players_array )      
end

balance_teams_button.signal_connect "clicked" do |_widget|
    balanced_teams = auto_balancer( comp_players_array )
    team1_players_array = balanced_teams[0]
    team2_players_array = balanced_teams[1]
    balance_window = Gtk::Window.new("Competing Teams")
    balance_window.set_size_request(880, 660)
    balance_window.set_border_width(10)   
    #Containers
    balance_box = Gtk::Box.new( :vertical, 10 ) 
    balance_sub_boxes = [
        balance_list_box = Gtk::Box.new( :horizontal, 5 ),
        balance_button_box = Gtk::Box.new( :horizontal, 5 )
    ]    
    team1_list_store = Gtk::ListStore.new( String, Float )
    team2_list_store = Gtk::ListStore.new( String, Float )
    #Widgets
    team1_tree = Gtk::TreeView.new( team1_list_store )
    team2_tree = Gtk::TreeView.new( team2_list_store )
    balance_buttons = [
    team1_button = Gtk::Button.new( :label => "Team One won!" ),
    draw_button = Gtk::Button.new( :label => "Draw" ),
    team2_button = Gtk::Button.new( :label => "Team Two won!" ),
    print_teams_button = Gtk::Button.new(:label => "Print Teams" )
    ]
    team1_columns = [
    team1_player_column = Gtk::TreeViewColumn.new( 
        "Player", renderer, text: 0 ),
    team1_mmr_column = Gtk::TreeViewColumn.new( 
        "MMR", renderer, text: 1 )
    ]
    team2_columns = [
    team2_player_column = Gtk::TreeViewColumn.new( 
        "Player", renderer, text: 0 ),
    team2_mmr_column = Gtk::TreeViewColumn.new( 
        "MMR", renderer, text: 1 )
    ]
    team1_list = Gtk::ScrolledWindow.new
    team2_list = Gtk::ScrolledWindow.new
    team1_list.add( team1_tree )
    team2_list.add( team2_tree )
    #Building
    team1_list.set_size_request(400, 300)
    team2_list.set_size_request(400, 300)
    balance_window.add( balance_box )
    balance_sub_boxes.each do |box|
        balance_box.add( box )
    end    
    balance_list_box.pack_start( team1_list, expand: true, 
    fill: true, padding: 5 )
    balance_list_box.pack_start( team2_list, expand: true, 
    fill: true, padding: 5 )
    balance_buttons.each do |button|
        balance_button_box.pack_start( button, 
        expand: true, fill: true, padding: 5 )
    end
    team1_columns.each do |column|
        team1_tree.append_column( column )
    end
    team2_columns.each do |column|
        team2_tree.append_column( column )
    end
    update_tree_view( team1_list_store, team1_players_array )
    update_tree_view( team2_list_store, team2_players_array )
    #Definitions
    team1_avg_mmr = average_mmr( team1_players_array )
    team2_avg_mmr = average_mmr( team2_players_array )
    #team1 def
    team1_button.signal_connect "clicked" do |_widget|
        players_mmr_updater( team1_players_array, team2_avg_mmr, 1, db_players_array, db_list_store )
        players_mmr_updater( team2_players_array, team1_avg_mmr, 0, db_players_array, db_list_store )

        update_tree_view( team1_list_store, team1_players_array )
        update_tree_view( team2_list_store, team2_players_array )

        comp_players_array.clear
        update_tree_view( comp_list_store, comp_players_array )

        balance_window.close        
    end
    #team2 def
    team2_button.signal_connect "clicked" do |_widget|
        players_mmr_updater( team1_players_array, team2_avg_mmr, 0, db_players_array, db_list_store )
        players_mmr_updater( team2_players_array, team1_avg_mmr, 1, db_players_array, db_list_store )

        update_tree_view( team1_list_store, team1_players_array )
        update_tree_view( team2_list_store, team2_players_array )

        comp_players_array.clear
        update_tree_view( comp_list_store, comp_players_array )

        balance_window.close
    end    
    #drawdef
    draw_button.signal_connect "clicked" do |_widget|

        players_mmr_updater( team1_players_array, team2_avg_mmr, 0.5, db_players_array, db_list_store )
        players_mmr_updater( team2_players_array, team1_avg_mmr, 0.5, db_players_array, db_list_store )

        update_tree_view( team1_list_store, team1_players_array )
        update_tree_view( team2_list_store, team2_players_array )

        comp_players_array.clear
        update_tree_view( comp_list_store, comp_players_array )

        balance_window.close
    end    
    #printteamsdef
    print_teams_button.signal_connect "clicked" do |_widget|
    text = ""

    puts one = "Team One Mmr #{'%.2f' % total_mmr(team1_players_array)}"
    text << one + "\n"
    team1_players_array.each do |player|
        puts player.name
        text << "#{player.name}\n"
    end

    text << "\n"

    puts two = "Team Two Mmr #{'%.2f' % total_mmr(team2_players_array)}"
    text << two + "\n"
    team2_players_array.each do |player|
        puts player.name
        text << "#{player.name}\n"
    end

    cb = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
    cb.set_text(text)
    $last_clipboard = cb
    end
    balance_window.show_all
end

#Methods
def update_tree_view(list_store, players_array)
  list_store.clear

  # Sort by highest MMR first
  sorted = players_array.sort_by { |player| -player.mmr.to_f }

  sorted.each do |player|
    iter = list_store.append
    iter[0] = player.name
    iter[1] = player.mmr
  end
end


#Runtime
window.signal_connect("delete-event") do |_widget| 
    save_playerdata( db_players_array )
    Gtk.main_quit 
end
update_tree_view( db_list_store, db_players_array )
window.show_all

Gtk.main