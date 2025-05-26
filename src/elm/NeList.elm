module NeList exposing (..)

import List.Extra
import Maybe.Extra
import Util


type alias NeList a =
    ( a, List a )


singleton : a -> NeList a
singleton a =
    ( a, [] )


append : NeList a -> NeList a -> NeList a
append ( h, list ) a =
    ( h, list ++ toList a )


head : NeList a -> a
head ( h, _ ) =
    h


last : NeList a -> a
last ( h, queue ) =
    case List.reverse queue of
        l :: _ ->
            l

        _ ->
            h


{-| Drop the first [amount] elements of the NeList
-}
drop : Int -> NeList a -> List a
drop amount ( h, list ) =
    if amount == 1 then
        list

    else if amount > 1 then
        List.drop (amount - 1) list

    else
        h :: list


{-| push an element to the beginning of the NeList
-}
push : a -> NeList a -> NeList a
push a ( h, list ) =
    ( a, h :: list )


{-| Decompose a neList into its body and last element. Return (xs, x), where x is the last element and xs is the body
-}
pop : NeList a -> ( List a, a )
pop ( h, list ) =
    case List.Extra.unconsLast list of
        Nothing ->
            ( [], h )

        Just ( l, body ) ->
            ( h :: body, l )


updateFirst : (a -> a) -> NeList a -> NeList a
updateFirst f ( h, list ) =
    ( f h, list )


updateLast : (a -> a) -> NeList a -> NeList a
updateLast f ( h, list ) =
    case List.Extra.unconsLast list of
        Nothing ->
            ( f h, [] )

        Just ( l, body ) ->
            ( h, body ++ [ f l ] )


appendWith : NeList a -> NeList a -> NeList a
appendWith a ( h, list ) =
    ( h, list ++ toList a )


toList : NeList a -> List a
toList ( h, list ) =
    h :: list


fromList : List a -> Maybe (NeList a)
fromList =
    List.Extra.uncons


length : NeList a -> Int
length ( _, list ) =
    1 + List.length list


map : (a -> b) -> NeList a -> NeList b
map func ( h, list ) =
    ( func h, List.map func list )


allMap : (a -> Maybe b) -> NeList a -> Maybe (NeList b)
allMap func ( h, list ) =
    Maybe.map2
        Tuple.pair
        (func h)
        (Maybe.Extra.traverse func list)


intersperse : a -> NeList a -> NeList a
intersperse elem ( h, list ) =
    ( h, elem :: List.intersperse elem list )


reverse : NeList a -> NeList a
reverse ( h, list ) =
    case List.reverse list of
        [] ->
            ( h, [] )

        l :: body ->
            ( l, body ++ [ h ] )


getAt : Int -> NeList a -> Maybe a
getAt index ( h, list ) =
    if index < 0 then
        getAt (-index - 1) (reverse ( h, list ))

    else if index == 0 then
        Just h

    else
        case list of
            [] ->
                Nothing

            next :: queue ->
                getAt (index - 1) ( next, queue )
