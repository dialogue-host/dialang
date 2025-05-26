module Fs.Tree exposing (..)

import Dict
import Fs
import Fs.Path
import NeList
import RemoteData exposing (RemoteData(..))


type Entry v
    = File (RemoteData String v)
    | Directory


empty : Fs.Tree v
empty =
    Dict.empty


singleton : Fs.Path -> Entry v -> Fs.Tree v
singleton path entry =
    insert path entry Dict.empty


get : Fs.Path -> Fs.Tree v -> Maybe (Entry v)
get (Fs.Path path) tree =
    case path of
        ( tail, [] ) ->
            Maybe.map
                (\entry ->
                    case entry of
                        Fs.Directory _ ->
                            Directory

                        Fs.File data ->
                            File data
                )
                (Dict.get tail tree)

        ( head, queueHead :: queue ) ->
            case Dict.get head tree of
                Just (Fs.Directory subTree) ->
                    get (Fs.Path ( queueHead, queue )) subTree

                _ ->
                    Nothing


insert : Fs.Path -> Entry v -> Fs.Tree v -> Fs.Tree v
insert path entry tree =
    update path (always (Just entry)) tree


remove : Fs.Path -> Fs.Tree v -> Fs.Tree v
remove path tree =
    update path (always Nothing) tree


{-| If a File of the Fs.Tree v is used as a directory in the Fs.Path, it will be replaced by a Directory
-}
update : Fs.Path -> (Maybe (Entry v) -> Maybe (Entry v)) -> Fs.Tree v -> Fs.Tree v
update (Fs.Path path) func tree =
    let
        updateSubTree subTree ( head, queueHead, queue ) =
            let
                queuePath =
                    Fs.Path ( queueHead, queue )
            in
            Dict.insert head
                (Fs.Directory <| update queuePath func subTree)
                tree

        funcWrapper : Maybe (Fs.Entry v) -> Maybe (Fs.Entry v)
        funcWrapper maybeEntry =
            let
                toTreeEntry outputEntry directoryTree =
                    case outputEntry of
                        Directory ->
                            Fs.Directory directoryTree

                        File newData ->
                            Fs.File newData
            in
            case maybeEntry of
                Just (Fs.Directory subTree) ->
                    Maybe.map
                        (\outputEntry -> toTreeEntry outputEntry subTree)
                        (func (Directory |> Just))

                Just (Fs.File data) ->
                    Maybe.map
                        (\outputEntry -> toTreeEntry outputEntry Dict.empty)
                        (func (File data |> Just))

                Nothing ->
                    Maybe.map
                        (\outputEntry -> toTreeEntry outputEntry Dict.empty)
                        (func Nothing)
    in
    case path of
        ( tail, [] ) ->
            Dict.update tail funcWrapper tree

        ( head, queueHead :: queue ) ->
            case Dict.get head tree of
                Just (Fs.Directory subTree) ->
                    updateSubTree subTree ( head, queueHead, queue )

                _ ->
                    case func Nothing of
                        Just _ ->
                            updateSubTree Dict.empty ( head, queueHead, queue )

                        Nothing ->
                            tree


{-| Join two Trees together.
The file's content priority is given in the following order: Success, Failure, Loading, NotAsked.
If they both are Success or Failure then we give priority to the first Fs.Tree v.
If the same path leads to a directory in one Fs.Tree v and to a file in the other, the directory is prioritized over the file.
-}
union : Fs.Tree v -> Fs.Tree v -> Fs.Tree v
union treeA treeB =
    let
        ( leftOfBTree, resultingTree ) =
            List.foldl
                (\( path, entry ) ( emptyingBTree, treeResult ) ->
                    case ( get path treeResult, entry ) of
                        ( Just (File _), Directory ) ->
                            ( remove path emptyingBTree
                            , insert path Directory treeResult
                            )

                        ( Just Directory, _ ) ->
                            ( emptyingBTree
                            , insert path Directory treeResult
                            )

                        ( Just (File _), File (Success content) ) ->
                            ( remove path emptyingBTree
                            , insert path (File (Success content)) treeResult
                            )

                        ( Just (File (Success content)), File _ ) ->
                            ( remove path emptyingBTree
                            , insert path (File (Success content)) treeResult
                            )

                        ( Just (File _), File (Failure error) ) ->
                            ( remove path emptyingBTree
                            , insert path (File (Failure error)) treeResult
                            )

                        ( Just (File (Failure error)), File _ ) ->
                            ( remove path emptyingBTree
                            , insert path (File (Failure error)) treeResult
                            )

                        ( Just (File _), File Loading ) ->
                            ( remove path emptyingBTree
                            , insert path (File Loading) treeResult
                            )

                        ( Just (File Loading), File _ ) ->
                            ( remove path emptyingBTree
                            , insert path (File Loading) treeResult
                            )

                        ( Just (File NotAsked), File NotAsked ) ->
                            ( remove path emptyingBTree
                            , insert path (File NotAsked) treeResult
                            )

                        ( Nothing, any ) ->
                            ( emptyingBTree
                            , insert path any treeResult
                            )
                )
                ( treeB, Dict.empty )
                (toList treeA)
    in
    List.foldl
        (\( path, entry ) tree -> insert path entry tree)
        resultingTree
        (toList leftOfBTree)


toList : Fs.Tree v -> List ( Fs.Path, Entry v )
toList tree =
    let
        rec : Fs.Path -> Fs.Entry v -> List ( Fs.Path, Entry v )
        rec runner entryRunner =
            case entryRunner of
                Fs.Directory subTree ->
                    List.foldl
                        (\( subEntryName, subEntry ) acc ->
                            rec (Fs.Path.dirChild runner subEntryName) subEntry
                                ++ acc
                        )
                        (List.singleton ( runner, Directory ))
                        (Dict.toList subTree)

                Fs.File data ->
                    List.singleton ( runner, File data )
    in
    List.foldl
        (\( rootStr, entry ) acc ->
            rec (Fs.Path (NeList.singleton rootStr)) entry
                :: acc
        )
        []
        (Dict.toList tree)
        |> List.concat


fromList : List ( Fs.Path, Entry v ) -> Fs.Tree v
fromList list =
    List.foldl
        (\( path, entry ) tree -> insert path entry tree)
        Dict.empty
        list
