#Class definition for Player objects
class Player
    attr_accessor :name, :mmr

    def initialize(name, mmr)
        @name = name
        @mmr = mmr
    end
end