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
5. (Optional) if you want to use migrations, make sure there is a `migrations` folder in the root directory of the resource

## Validations
Right now if a table or column isn't found, an error will be thrown in the server console. I will try to work this out better in the future

## Things I will be working on
Things I am going to be working on!

- Adding `mysql-async` support

### Data
- ThenInclude - nested includes like users → orders → products

### Convenience
- Exists - returns boolean wether record exists

## Functionalities
- [Setting Entity](#setting-entity)
- [ToList](#tolist)
- [Count](#count)
- [Where](#where-clause)
- [Select](#select)
- [Insert](#insert)
- [Include](#include)
- [Delete](#delete)
- [Update](#update)
- [First](#first)
- [Migrations](#migration)
- [OrderBy](#orderby--orderbydescending)
- [FindById](#findbyid)

### Setting entity
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

### First
To get the first row of an query, you can use the First() function in the same way as the ToList() function

```lua
local players = exports['FiveORM']:DbSet('players')
local results = players:Where('money', 200):Where('active', true):First()
print(json.encode(results))
```

### Count
To get the count of records, you can use the Count() function
You can add a :Where() clause to this

```lua
local orders = exports['FiveORM']:DbSet('orders')
local results = orders:Count()
print(results)
results = orders:Where('total', 10):Count()
print(results)
```

### Migration
Since this resource is inspired by the Entity Framework from C#, it also supports migrations.

If you don't know what these are: You can design a Lua table as a database table!

#### Properties

When defining an entity for migrations, each property supports the following options:


| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `type` | string | Yes | The SQL column type (e.g. `int`, `varchar`, `bool`) |
| `nullable` | boolean | Yes | Whether the column allows NULL values |
| `maxlength` | number | No | Max length for `varchar` columns |
| `primaryKey` | boolean | No | Marks the column as the PRIMARY KEY |
| `unique` | boolean | No | Marks the column as UNIQUE |

#### Example of properties

```lua
properties = {
    id = {
        type = 'int',
        nullable = false,
        primaryKey = true
    },
    name = {
        type = 'varchar',
        nullable = true,
        maxlength = 100,
        unique = true
    },
    active = {
        type = 'bool',
        nullable = false
    }
}
```

When running the migration adding command, the script will search for export:
`SetEntities()`

#### Example of creating a migration
```lua
function Users()
    local entities = {}
    local entity = {
        tableName = 'Test',
        properties = {
            id = {
                type = 'int',
                nullable = false,
                primaryKey = true
            },
            name = {
                type = 'varchar',
                nullable = true,
                maxlength = 100
            },
            active = {
                type = 'bool',
                nullable = false,
            }
        }
    }

    table.insert(entities, entity)

    entity = {
        tableName = 'Blub',
        properties = {
            id = {
                type = 'int',
                nullable = false,
                primaryKey = true
            },
            order = {
                type = 'varchar',
                nullable = true,
                maxlength = 100
            },
        }
    }

    table.insert(entities, entity)

    return entities
end

-- this export will be called by the script
exports("SetEntities", function()
    return Users()
end)
```

To create a migration
`/migration (script of entities) (migration name)`

To run all the migrations available
`/run-migrations`

### OrderBy / OrderByDescending
To order the data you can use either the OrderBy() function or the OrderByDesc() function

```lua
local orders = exports['FiveORM']:DbSet('orders')
local results = orders:OrderBy():ToList()
print(json.encode(results))
```

### FindById
To find a record by the primary key you can use the FindById() function

```lua
local orders = exports['FiveORM']:DbSet('orders')
local results = orders:FindById(1)
print(json.encode(results))
```

## Example
```lua
local players = exports['FiveORM']:DbSet('players')
local results = players:Where('money', 200):Where('active', true):ToList()
print(json.encode(results))
```