module Util exposing (..)


switchArgs : (a -> b -> c) -> b -> a -> c
switchArgs func b a =
    func a b


each =
    { top = 0, left = 0, right = 0, bottom = 0 }


unzipTriple : List ( a, b, c ) -> ( List a, List b, List c )
unzipTriple list =
    List.foldr
        (\( a, b, c ) ( accA, accB, accC ) ->
            ( a :: accA
            , b :: accB
            , c :: accC
            )
        )
        ( [], [], [] )
        list
