import LogicKit


let zero = Value (0)

func succ (_ of: Term) -> Map {
    return ["succ": of]
}

func toNat (_ n : Int) -> Term {
    var result : Term = zero
    for _ in 1...n {
        result = succ (result)
    }
    return result
}

struct Position : Equatable, CustomStringConvertible {
    let x : Int
    let y : Int

    var description: String {
        return "\(self.x):\(self.y)"
    }

    static func ==(lhs: Position, rhs: Position) -> Bool {
      return lhs.x == rhs.x && lhs.y == rhs.y
    }

}


// rooms are numbered:
// x:1,y:1 ... x:n,y:1
// ...             ...
// x:1,y:m ... x:n,y:m
func room (_ x: Int, _ y: Int) -> Term {
    return Value (Position (x: x, y: y))
}

func doors (from: Term, to: Term) -> Goal {   //determines if the room 'from' goes to the room 'to' by a door
    return from === room(2, 1) && to === room(1, 1) || from === room(3, 1) && to === room(2, 1) || from === room(4, 1) && to === room(3, 1) ||
           from === room(4, 2) && to === room(4, 1) || from === room(3, 2) && to === room(4, 2) || from === room(2, 2) && to === room(3, 2) ||
           from === room(1, 2) && to === room(2, 2) || from === room(1, 2) && to === room(1, 1) || from === room(1, 3) && to === room(1, 2) ||
           from === room(2, 3) && to === room(1, 3) || from === room(2, 3) && to === room(2, 2) || from === room(3, 2) && to === room(3, 3) ||
           from === room(4, 2) && to === room(4, 3) || from === room(4, 4) && to === room(3, 4) || from === room(3, 4) && to === room(3, 3) ||
           from === room(3, 4) && to === room(2, 4) || from === room(2, 4) && to === room(2, 3) || from === room(1, 4) && to === room(1, 3)

}

func entrance (location: Term) -> Goal {    //determines if the room 'location' is an entrance of the maze
    return location === room(4, 4) || location === room(1, 4)
}

func exit (location: Term) -> Goal {    //determines if the room 'location' is an exit of the maze
    return location === room(4, 3) || location === room(1, 1)
}

func minotaur (location: Term) -> Goal {    //determines if the Minotaur is located in the room 'location'
    return location === room(3, 2)
}

func path (from: Term, to: Term, through: Term) -> Goal {     //determines if the room 'from' goes to the room 'to' by the path 'through'. The goal returned fails if there is no path between the two rooms,
                                                              //or if the path 'through' isn't the good one
    return doors(from: from, to: to) && through === List.empty || delayed(fresh {x in fresh {y in (through === List.cons(x, y) && doors(from: from, to: x) && path(from: x, to: to, through: y))}})
}

func battery (through: Term, level: Term) -> Goal {     //determines if there is enough battery to cross the path 'through' of the maze
    return delayed(fresh {x in (level === succ(x) && batteryBis(through: through, level: x))})
}

func batteryBis(through: Term, level: Term) -> Goal {     //this recursive function completes the function 'battery'
    return delayed(fresh {x in level === succ(x)}) && through === List.empty || (delayed(fresh {x in fresh {y in fresh {new_battery in through === List.cons(x,y) && level === succ(new_battery) &&
           batteryBis(through: y, level: new_battery) }}}))
}

func winning (through: Term, level: Term) -> Goal {    //determines if the path 'through' goes from an entrance to an exit of the maze, if it crosses the room where the Minotaur is located, and if there is enough battery to cross this path
    return battery(through: through, level: level) && withMinotaur(through: through) && delayed(fresh {x in fresh {y in path(from: x, to: y, through: through) && entrance(location: x) && exit(location: y)}})
}

func withMinotaur(through: Term) -> Goal {    //determines if the path 'through' crosses the room where the Minotaur is located
    return delayed(fresh {x in fresh {y in (minotaur(location: through) || through === List.cons(x, y) && (withMinotaur(through: y) || minotaur(location: x)))}})
}
