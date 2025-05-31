module Fs.Tree exposing (..)

import Dict
import Fs exposing (..)
import Fs.Path as Path
import Fs.InternalTree as ITree


empty : Context -> Tree v
empty context =
    (context, ITree.empty)


singletonFile : Context -> Path -> FileData v -> Tree v
singletonFile context path fileData =
    insert path (File fileData) (empty context)


singletonDir : Context -> Path -> Tree v
singletonDir context path =
    insert path (Directory ITree.empty) (empty context)


get : Path -> Tree v -> Maybe (Entry v)
get path (context,tree) =
    ITree.get (Path.toRelative context path) tree


insert : Path -> Entry v -> Tree v -> Tree v
insert path entry (context, tree) =
    (context, ITree.insert (Path.toRelative context path) entry tree)


insertFile : Path -> FileData v -> Tree v -> Tree v
insertFile path fileData tree =
    insert path (File fileData) tree


insertDir : Path -> Tree v -> Tree v
insertDir path tree =
    insert path (Directory Dict.empty) tree


remove : Path -> Tree v -> Tree v
remove path tree =
    update path (always Nothing) tree


{-| If `func Nothing` returns `Just _` and a File of the Tree v is used as a directory in its Path, it will be replaced by a Directory
-}
update : Path -> (Maybe (Entry v) -> Maybe (Entry v)) -> Tree v -> Tree v
update path func (context, tree) =
    (context, ITree.update (Path.toRelative context path) func tree)


{-| Combine two trees. If there is a collision, preference is given to the first tree.
It keeps the context of the first tree.
-}
union :
    { keepSecondFileDataWhenFistIsNotAsked : Bool }
    -> Tree v -> Tree v -> Tree v
union setting (context, treeA) (_, treeB) =
    ITree.union setting treeA treeB
    |> Tuple.pair context


changeContext : Context -> Tree v -> Tree v
changeContext newContext oldTree =
    toList oldTree |> fromList newContext


{-| Returns a list of all files and empty directories.
-}
toList : Tree v -> List (Path, Entry v)
toList (context, tree) =
    ITree.toList tree |> List.map (Tuple.mapFirst (Path.toAbsolute context))


fromList : Context -> List ( Path, Entry v ) -> Tree v
fromList context list =
    List.foldl
        (\( path, entry ) tree -> insert path entry tree)
        (empty context)
        list


setFileToLoading : Path -> Tree v -> Tree v
setFileToLoading path (context, tree) =
    ITree.setFileToLoading (Path.toRelative context path) tree
    |> Tuple.pair context


setFileToFailure : Path -> String -> Tree v -> Tree v
setFileToFailure path errorMsg (context, tree) =
    ITree.setFileToFailure (Path.toRelative context path) errorMsg tree
    |> Tuple.pair context
