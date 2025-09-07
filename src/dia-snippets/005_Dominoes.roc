# This puzzle comes from the [Roc track on Exercism](https://exercism.org/tracks/roc/exercises/dominoes).

app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.19.0/Hj-J_zxz7V9YurCSTFcFdu6cQJie4guzsPMUi5kBYUk.tar.br",
}
import pf.Stdout

main! = |_args|
    Stdout.line!(
        Inspect.to_str(find_chain(
          [(4, 2), (2, 3), (3, 1), (1, 5), (5, 6), (6, 4)]
        ))
    )

import List exposing [concat,prepend]

Domino : (U8, U8)
Error : [DisjointedGraph, DeadEnd]

find_chain : List Domino -> Result (List Domino) Error
find_chain = |dominoes|
    find_chain_rec(dominoes, [], [])

find_chain_rec : List Domino, List Domino, List Domino -> Result (List Domino) Error
find_chain_rec = | bag, possible, acc |
    when (bag, possible, acc) is
        ([h, .. as q], [], []) ->
            find_chain_rec(q, [], [h])

        ([_, ..], [], [(prev, _), ..]) ->
            {matching, others} = split(prev, bag)
            if List.is_empty(matching)
            then Err DisjointedGraph
            else find_chain_rec(others, matching, acc)

        (_, [h, .. as q], _) ->
            when find_chain_rec(concat(bag,q), [], prepend(acc,h)) is
                Err DisjointedGraph ->
                    Err DisjointedGraph

                Err DeadEnd ->
                    find_chain_rec(prepend(bag,h), q, acc)

                Ok solution ->
                    Ok solution

        ([], [], [(hl, _), .., (_, lr)]) | ([], [], [(hl, lr)]) ->
            if hl == lr
            then Ok acc
            else Err DeadEnd

        ([], [], []) ->
            Ok []

        _ ->
            Err DeadEnd



split : U8, List Domino -> { matching : List Domino, others : List Domino }
split = | n, bag |
    split_rec(n, bag, [], [])

split_rec : U8, List Domino, List Domino, List Domino -> { matching : List Domino, others : List Domino }
split_rec = | n, bag, matching, others |
    when bag is
        [(hl, hr), .. as q] if n == hr ->
            split_rec(n, q, prepend(matching, (hl, hr)), others)

        [(hl, hr), .. as q] if n == hl ->
            split_rec(n, q, prepend(matching,(hr, hl)), others)

        [h, .. as q] ->
            split_rec(n, q, matching, prepend(others,h))

        [] ->
            { matching : matching, others : others }
