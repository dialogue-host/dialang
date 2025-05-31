module Fs.InternalTree exposing (..)

import Dict
import Fs exposing (..)
import Fs.Path as Path
import Fs.FileData as FileData


empty : InternalTree v
empty =
    Dict.empty


singleton : Path -> Entry v -> InternalTree v
singleton path entry =
    insert path entry Dict.empty


get : Path -> InternalTree v -> Maybe (Entry v)
get (Path path) tree =
    case path of
        ( tail, [] ) ->
            Dict.get tail tree

        ( head, queueHead :: queue ) ->
            case Dict.get head tree of
                Just (Directory subTree) ->
                    get (Path ( queueHead, queue )) subTree

                _ ->
                    Nothing


insert : Path -> Entry v -> InternalTree v -> InternalTree v
insert path entry tree =
    union
        { keepSecondFileDataWhenFistIsNotAsked = False }
        (singleton path entry)
        tree


remove : Path -> InternalTree v -> InternalTree v
remove path tree =
    update path (always Nothing) tree


{-| If a File of the InternalTree v is used as a directory in the Path, it will be replaced by a Directory
-}
update : Path -> (Maybe (Entry v) -> Maybe (Entry v)) -> InternalTree v -> InternalTree v
update (Path path) func tree =
    case path of
        ( tail, [] ) ->
            Dict.update tail func tree

        ( head, queueHead :: queue ) ->
            case Dict.get head tree of
                Just (Directory subTree) ->
                    update (Path (queueHead, queue)) func subTree

                _ ->
                    case func Nothing of
                        Just newEntry ->
                            let subTree = singleton (Path path) newEntry in
                            Dict.insert head (Directory subTree) tree

                        Nothing ->
                            tree


{-| Combine two trees. If there is a collision, preference is given to the first tree.
-}
union : { keepSecondFileDataWhenFistIsNotAsked : Bool } -> InternalTree v -> InternalTree v -> InternalTree v
union setting treeA treeB =
    let
        entryUnion : Entry v -> Entry v -> Entry v
        entryUnion aEntry bEntry =
            case (aEntry, bEntry) of
                (Directory aSubTree, Directory bSubTree) ->
                    union setting aSubTree bSubTree
                    |> Directory

                (File NotAsked, File _) ->
                    if setting.keepSecondFileDataWhenFistIsNotAsked
                    then bEntry
                    else aEntry

                _ ->
                    aEntry
    in
    -- we insert treeA into treeB
    List.foldl
        (\( head, aEntry ) treeAcc ->
            Dict.update head
                (\ maybeBEntry ->
                    case maybeBEntry of
                        Nothing -> Just aEntry
                        Just bEntry -> Just (entryUnion aEntry bEntry)
                )
                treeAcc
        )
        treeB
        (Dict.toList treeA)


{-| Returns a list of all files and empty directories.
-}
toList : InternalTree v -> List ( Path, Entry v )
toList tree =
    List.foldl
        (\( head, entry ) acc ->
            case entry of
                Directory subTree ->
                    if Dict.isEmpty subTree
                    then (Path (head, []), entry) :: acc
                    else
                        List.map (Tuple.mapFirst (Path.insertLeft head)) (toList subTree)
                        ++ acc

                File _ ->
                    ( Path (head, []), entry ) :: acc
        )
        []
        (Dict.toList tree)


fromList : List ( Path, Entry v ) -> InternalTree v
fromList list =
    List.foldl
        (\( path, entry ) tree -> insert path entry tree)
        Dict.empty
        list


setFileToLoading : Path -> InternalTree v -> InternalTree v
setFileToLoading path tree =
    update path
        (\ maybeEntry ->
            case maybeEntry of
                Just (File data) ->
                    { previousSuccess = FileData.getPreviousSuccess data }
                    |> (Loading >> File >> Just)

                _ ->
                    { previousSuccess = Nothing }
                    |> (Loading >> File >> Just)
        )
        tree


setFileToFailure : Path -> String -> InternalTree v -> InternalTree v
setFileToFailure path errorMsg tree =
    update path
        (\ maybeEntry ->
            case maybeEntry of
                Just (File data) ->
                    { previousSuccess = FileData.getPreviousSuccess data
                    , errorMsg = errorMsg
                    }
                    |> (Failure >> File >> Just)

                _ ->
                    { previousSuccess = Nothing, errorMsg = errorMsg }
                    |> (Failure >> File >> Just)
        )
        tree
