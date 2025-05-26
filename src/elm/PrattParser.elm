module PrattParser exposing (..)

-- This code originates from the following article : https://martin.janiczek.cz/2023/07/03/demystifying-pratt-parsers.html

import Html


main =
    parse exampleTokens
        |> Debug.toString
        |> Html.text



----


type Token
    = TNum Int
    | TOp Binop


type Binop
    = Add
    | Sub
    | Mul
    | Div
    | Pow


type Expr
    = Num Int
    | Op Expr Binop Expr


exampleTokens : List Token
exampleTokens =
    [ TNum 1
    , TOp Add
    , TNum 2
    , TOp Sub
    , TNum 3
    , TOp Mul
    , TNum 4
    , TOp Add
    , TNum 5
    , TOp Div
    , TNum 6
    , TOp Pow
    , TNum 7
    , TOp Sub
    , TNum 8
    , TOp Mul
    , TNum 9
    ]


{-| Larger precedence means higher priority when chomping operations.
-}
precedence : Binop -> Int
precedence binop =
    case binop of
        Add ->
            1

        Sub ->
            1

        Mul ->
            2

        Div ->
            2

        Pow ->
            3


{-| Our top-level parser. The user doesn't care about the rest of the tokens
so we throw these away.
-}
parse : List Token -> Maybe Expr
parse tokens =
    case pratt 0 tokens of
        Just ( expr, tokensAfterExpr ) ->
            Just expr

        Nothing ->
            Nothing


{-| We're only parsing a simplified language, but in a more real-world one
you'd also have things like -5, !False and (1+3).
-}
prefix : List Token -> Maybe ( Expr, List Token )
prefix tokens =
    case tokens of
        [] ->
            Nothing

        (TNum n) :: rest ->
            Just ( Num n, rest )

        (TOp _) :: _ ->
            Nothing


{-| Parse a prefix expression then run the loop.
-}
pratt : Int -> List Token -> Maybe ( Expr, List Token )
pratt precLimit tokens =
    case prefix tokens of
        Nothing ->
            Nothing

        Just ( left, tokensAfterPrefix ) ->
            prattLoop precLimit left tokensAfterPrefix


prattLoop : Int -> Expr -> List Token -> Maybe ( Expr, List Token )
prattLoop precLimit left tokensAfterLeft =
    case tokensAfterLeft of
        -- The next token is an operator! Let's find its precedence.
        (TOp op) :: tokensAfterOp ->
            let
                opPrec : Int
                opPrec =
                    precedence op
            in
            -- Now, are we allowed to parse the next expression
            -- or is it outside the limit?
            if opPrec > precLimit then
                -- We can parse it! Spawn a child Pratt parser.
                case pratt opPrec tokensAfterOp of
                    -- Whatever the child Pratt parser did,
                    -- we take it and combine it with our `left`.
                    Just ( right, tokensAfterRight ) ->
                        let
                            newLeft : Expr
                            newLeft =
                                Op left op right
                        in
                        -- There might be more on our level (like in 1+2-3),
                        -- so let's loop.
                        prattLoop precLimit newLeft tokensAfterRight

                    -- An error, propagate it.
                    Nothing ->
                        Nothing

            else
                -- We shouldn't parse this op.
                -- Return what we have.
                -- (Note our token list points at the op, not at the token after)
                Just ( left, tokensAfterLeft )

        -- Either we ran out of tokens or found something that's not an operator.
        -- Let's return what we have.
        _ ->
            Just ( left, tokensAfterLeft )
