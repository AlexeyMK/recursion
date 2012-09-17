_ = require 'underscore'
###
from: 
to:
    1
    push: true

from: 2
to: 1
push: true

graph = [
    from: 0
    to: [15, 14]
    to_a: [0]
,
    from: 1
    to: []
    to_down: [3]
,



]
###

raw_graph:
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

neighbors = (state) ->
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
            top = _.last state.stack
            for position in graph.up_neighbors[top][state.position]
                position: position
                stack: immutable_pop state.stack
        else
            []

    jump_neighbors = 
        if state.stack.length > 0
            top = _.last state.stack
            for {position, letter} in graph.jump_neighbors[top][state.position]
                position: position, 
                stack: immutable_push (immutable_pop state.stack), letter
        else
            []

    _.concat flat_neighbors, down_neighbors, up_neighbors, jump_neighbors





