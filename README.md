# FiveORM for FiveM
> EF Core–style Entity Framework in Lua — built for FiveM resources

An Entity Framework Core inspired SQL framework for FiveM, giving the opportunity
for things like Where clauses in entity form.
---

## Requirements
- [OXmysql](https://github.com/overextended/oxmysql)

## Installation
1. Download the latest version from the [latest release page](https://github.com/YouriOkken/FiveORM/releases/latest)
2. Drop the `FiveORM` folder into your `resources` folder
3. Add to your `server.cfg`:
   ```
   ensure FiveORM
   ensure my-resource   # FiveORM must start first
   ```
4. Make sure `oxmysql` is already running

## Validations
Right now if a table or column isn't found, an error will be thrown in the server console. I will try to work this out better in the future<br>
I am also working on returning the right data/returning anything in general

## Things I will be working on
Things I am going to be working on!

- Adding `mysql-async` support

### Query building
- FirstOrDefault - returns first match or nil
- OrderBy / OrderByDescending
- Count
- Any - returns true/false if record exists

### Data
- ThenInclude - nested includes like users → orders → products

### Schema / migrations
Migrate — auto create tables based on a schema definition

### Convenience
- FindById - shorthand for Where id = x + FirstOrDefault
- Exists - probably going to be combined with Any() but with an column option (like delete function)

## Functionalities
- [ToList](#tolist)
- [Where](#where-clause)
- [Select](#select)
- [Insert](#insert)
- [Include](#include)
- [Delete](#delete)
- [Update](#update)

## Setting entity
Setting an entity will define what table will be used and gives back the functions

```lua
local entity = exports['FiveORM']:DbSet(tablename)
```

### ToList
To get all the data of a table, you can use the ToList() function Included when setting an Entity
```lua
local entity = exports['FiveORM']:DbSet(tablename)
local data = entity:ToList();
```

### Where clause
To filter data, you can add the :Where(column, value). **These are stackable!**
```lua
local entity = exports['FiveORM']:DbSet(tablename)
local data = entity:Where('name', 'John Doe'):Where('money', 100):ToList();
```

### Select
To select specific properties you can add the :Select() function.
```lua
local entity = exports['FiveORM']:DbSet(tablename)
local data = entity:Where('name', 'John Doe'):Select('id', 'name'):ToList();
```

### Insert
To insert a new record, use the :Add() function.

Returns: The id of the newly made record if succesfull, otherwise nil
```lua
local entity = exports['FiveORM']:DbSet(tablename)
local playerId = entity:Add({ name = 'John Doe', cash = 100 })
print("Player added with ID: " .. tostring(playerId))
```

### Include
To make an include to another table you can use the Include() function
Mind, the parameter is the foreign key column in the **base** table

```lua
local orders = exports['FiveORM']:DbSet('orders')
local results = orders:Include("player_id"):ToList()
```

### Delete
To delete 1 or more rows, you can use the Delete() function
This function accepts 2 parameters
1. value
2. column
Column can be nil, if this is the case the script will check for the primary key of the set table

```lua
local orders = exports['FiveORM']:DbSet('orders')
orders:Delete(6) -- the scripts will check for the primary key column of 'orders'
orders:Delete(100, 'total') -- the script will check for a column 'total' in 'orders'
```

### Update
To update 1 or more rows, you can use the Update() function
This functions needs a :Where() clause to prevent mass-update

```lua
local orders = exports['FiveORM']:DbSet('orders')
local results = orders:Where('id', 1):Update('total', 15)
```

## Example
```lua
local players = exports['FiveORM']:DbSet('players')
local results = players:Where('money', 200):Where('active', true):ToList()
print(json.encode(results))
```