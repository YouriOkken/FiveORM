Usage in other scripts
```lua
local Player = exports['FiveORM']:DbSet('players')
local results = Citizen.Await(Player:ToListAsync())
```