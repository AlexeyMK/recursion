###
   TODO:
    - fix the "sometimes positions are ints and sometimes strings" problem
    - optimize search:
      - "already visited" list
###

raw_graph =
    flat_neighbors:
        0: [15, 14]
        2: [11]
        7: [9, 12]
        9: [12]
        10: [13]
        14: [15]
    down_neighbors:
        0: [{position: 0, letter: 'A'}]
        1: [{position: 3, letter: 'A'}]
        2: [
            {position: 4, letter: 'A'}
            {position: 0, letter: 'C'}
            {position: 6, letter: 'B'}
            ]
        3: [{position: 0, letter: 'B'}]
        4: [{position: 3, letter: 'B'}]
        5: [{position: 7, letter: 'B'}]
        6: [
            {position: 5, letter: 'C'}
            {position: 2, letter: 'A'}
            ]
        7: [{position: 10, letter: 'A'}]
        8: [{position: 2, letter: 'B'}]
        9: [{position: 10, letter: 'A'}]
        10: [{position: 13, letter: 'A'}]
        11: [
            {position: 0, letter: 'C'}
            {position: 6, letter: 'B'}
            ]
        12: [{position: 10, letter: 'A'}]
        13: [{position: 13, letter: 'A'} ]
        14: [{position: 0, letter: 'A'} ]
        15: [{position: 0, letter: 'A'} ]

    jump_neighbors:
        A:
            2: [{position: 5, letter: 'C'}]
            4: [
                {position: 6, letter: 'B'}
                {position: 0, letter: 'C'}
                ]
            7: [{position: 15, letter: 'B'}]
            8: [{position: 12, letter: 'C'}]
            9: [{position: 15, letter: 'A'}]
        B:
            6: [{position: 0, letter: 'C'}]
            10: [{position: 3, letter: 'C'}]
            13: [{position: 14, letter: 'C'}]
        C:
            6: [{position: 7, letter: 'C'}]


start = {position: 11, stack: ['A']}
end = {position: 9, stack: ['C']}


immutable_push = (stack, element) ->
    stack.concat [element]

immutable_pop = (stack) ->
    stack[0...stack.length - 1]

last = (arr) -> arr[arr.length - 1]

get_neighbors = (state) ->
    flat_neighbors =
        for position in graph.flat_neighbors[state.position]
            position: position
            stack: state.stack

    down_neighbors =
        for {position, letter} in graph.down_neighbors[state.position]
            position: position
            stack: immutable_push state.stack, letter

    up_neighbors =
        if state.stack.length > 0
            top = last state.stack
            for position in graph.up_neighbors[top][state.position]
                position: position
                stack: immutable_pop state.stack
        else
            []

    jump_neighbors =
        if state.stack.length > 0
            top = last state.stack
            for {position, letter} in graph.jump_neighbors[top][state.position]
                position: position,
                stack: immutable_push (immutable_pop state.stack), letter
        else
            []

    [].concat flat_neighbors, down_neighbors, up_neighbors, jump_neighbors

echo = console.log

generate_graph = (raw_graph) ->
    flat_neighbors = {}
    for node in [0..15]
        flat_neighbors[node] = []
    for from, tos of raw_graph.flat_neighbors
        flat_neighbors[from] = flat_neighbors[from].concat(tos)
    for from, tos of raw_graph.flat_neighbors
        for back_to in tos
            flat_neighbors[back_to].push(parseInt(from))

    down_neighbors = {}
    for node in [0..15]
        down_neighbors[node] = raw_graph.down_neighbors[node] ? []

    up_neighbors = {}
    for letter in 'ABC'  # initialize
        up_neighbors[letter] = {}
        for node in [0..15]
            up_neighbors[letter][node] = []
    for from, tos of raw_graph.down_neighbors
        for to in tos
            up_neighbors[to.letter][to.position].push(from)

    jump_neighbors = {}
    for letter in 'ABC'
        jump_neighbors[letter] = {}
        for node in [0..15]
            jump_neighbors[letter][node] = []

    # forward edges
    for letter, pairs of raw_graph.jump_neighbors
        for from, tos of pairs
            jump_neighbors[letter][from] =
                jump_neighbors[letter][from].concat(tos)

    # back edges
    for letter, pairs of raw_graph.jump_neighbors
        for from, tos of pairs
            for to in tos
                jump_neighbors[to.letter][to.position].push
                    position: from
                    letter: letter

    {flat_neighbors, down_neighbors, up_neighbors, jump_neighbors}

shortest_path = (from, to, graph) ->
    # does a BFS traversal with a queue
    # state on stack: [current_from, [history]]
    queue = [[from, []]]
    history_size = 0

    while true
        [current, history] = queue[0]
        if history_size < history.length
            echo "now at paths of lengths #{history.length}"
            history_size = history.length


        if current.position == to.position and
           current.stack.toString() == to.stack.toString()
            return history
        else
            new_history = immutable_push(history, current)
            neighbors = get_neighbors current
            queued_neighbors =
                for neighbor in neighbors
                    [neighbor, new_history]
            queue = queue[1..].concat(queued_neighbors)

graph = generate_graph raw_graph
echo shortest_path(start, end, graph)

