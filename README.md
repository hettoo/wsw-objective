# Warsow Objective

Gametype script framework.

## Design

All these files should appear in the `src/progs/gametypes/` folder here.

`objective.gt`:
Includes all files listed below.

`objective.as`:
No class, creates a global Map object and connects the callbacks to it.

`objective/Core.as`:
Implements no objective, but converts events and has a bunch of objects that
are ready to be used by the Map.

`objective/core/Destroyable.as`:
Just an example for a class that implements a type of objective.

`objective/DefaultCore.as`:
Default map script core, implementing the default objective. Inherits Core.

`objective/Map.as`:
Map script. Inherits either DefaultCore or Core if supplied by the map,
DefaultCore otherwise.
