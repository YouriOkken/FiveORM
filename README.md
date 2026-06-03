# FiveORM for FiveM
> EF Core–style Entity Framework in Lua — built for FiveM resources

A Entity Framework Core inspired SQL framework for FiveM, giving the opportunity
for things like Where clauses in entity form.
---

## Installation

1. Drop the `FiveORM` folder into your `resources` folder
2. Add to your `server.cfg`:
   ```
   ensure FiveORM
   ensure my-resource   # FiveORM must start first
   ```
3. Make sure `oxmysql` or `mysql-async` is already running

## Setting entity
```lua
local entity = exports['FiveORM']:DbSet(tablename)
```

## Functionality

### ToListAsync
To get all the data of an table, you can use the ToListAsync() function Included when setting an Entity
```lua
local entity = exports['FiveORM']:DbSet(tablename)
local data = entity:ToListAsync();
```

### Where clause
To filter data, you can add the :Where(column, value). <b>These are stackable!</b>
```lua
local entity = exports['FiveORM']:DbSet(tablename)
local data = entity:Where('name', 'John Doe'):Where('money', 100):ToListAsync();
```

## Example
```lua
local players = exports['FiveORM']:DbSet('players')
local results = players:Where('money', 200):Where('active', true):ToListAsync()
```