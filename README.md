# FiveORM for FiveM
> EF Core–style Entity Framework in Lua — built for FiveM resources

All the below is coming soon:
---

## Installation

1. Drop the `FiveORM` folder into your `resources` folder
2. Add to your `server.cfg`:
   ```
   ensure FiveORM
   ensure my-resource   # FiveORM must start first
   ```
3. Make sure `oxmysql` or `mysql-async` is already running

---

## Quickstart

### 1. Create a context (one per resource)

```lua
-- server/context.lua
local Context = exports['FiveORM']:CreateContext('my-resource')
```

### 2. Register your models

```lua
local Player = Context:RegisterModel('Player', {
    table      = 'players',
    primaryKey = 'identifier',
    fields = {
        identifier = { type = 'string', required = true },
        name       = { type = 'string', required = true, maxLength = 50 },
        job        = { type = 'string', maxLength = 30 },
        money      = { type = 'int' },
    },
    relations = {
        vehicles = {
            type         = 'HasMany',
            model        = 'Vehicle',
            foreignKey   = 'owner',
            principalKey = 'identifier',
        },
    },
})
```

### 3. Add migrations

```lua
Context:AddMigration('001_CreatePlayersTable', {
    up = function(schema)
        schema:CreateTable('players', {
            identifier = { type = 'string', length = 60, primaryKey = true, nullable = false },
            name       = { type = 'string', length = 50, nullable = false },
            job        = { type = 'string', length = 30, default = 'unemployed' },
            money      = { type = 'int', default = 0 },
        })
    end,
    down = function(schema)
        schema:DropTable('players')
    end,
})
```

### 4. Run migrations (server console)

```
/FiveORM migrate my-resource
/FiveORM migrate          ← run all contexts at once
/FiveORM list             ← list registered contexts
```

---

## CRUD

### Find (by primary key)
```lua
local player = Citizen.Await(Player:Find('steam:abc123'))
```

### Add (INSERT)
```lua
local ok, errors, entity = Citizen.Await(Player:Add({
    identifier = 'steam:xyz',
    name       = 'John',
    job        = 'police',
    money      = 1000,
}))

if not ok then
    for _, err in ipairs(errors) do print(err) end
end
```

### SaveChanges (UPDATE)
```lua
local player = Citizen.Await(Player:Find('steam:abc'))
player.money = player.money + 500

local ok, errors = Citizen.Await(Player:SaveChanges(player))
```

### Remove (DELETE)
```lua
local player = Citizen.Await(Player:Find('steam:abc'))
Citizen.Await(Player:Remove(player))

-- Batch delete
Citizen.Await(Player:RemoveWhere({ job = 'banned' }))
```

---

## Query Builder (LINQ style)

All methods are chainable. Always ends with a **terminal method**.

### Where
```lua
-- Multiple fields (AND)
Player:Where({ job = 'police', job_grade = 3 })

-- With operator
Player:Where('money', '>', 10000)
Player:Where('name',  '=', 'John')    -- shorthand: Where('name', 'John')

-- OR
Player:Where({ job = 'police' }):OrWhere({ job = 'mechanic' })

-- NULL checks
Player:WhereNull('last_seen')
Player:WhereNotNull('job')

-- IN list
Player:WhereIn('identifier', { 'steam:a', 'steam:b', 'steam:c' })
```

### Include (Eager Loading)
```lua
-- Automatically loads relations in a single query
Player:Where({ job = 'police' }):Include('vehicles'):ToList()

-- Multiple includes
Player:Where('identifier', id)
      :Include('vehicles')
      :Include('offenses')
      :Include('gangs')
      :FirstOrDefault()

-- player.vehicles = { {...}, {...} }
-- player.offenses = { {...} }
-- player.gangs    = { {...} }   ← BelongsToMany via pivot table
```

### Ordering & Paging
```lua
Player:OrderBy('name')
      :OrderByDescending('money')
      :Skip(20)
      :Take(10)
      :ToList()
```

### Terminal methods
| Method              | Description                          | Returns          |
|---------------------|--------------------------------------|------------------|
| `:ToList()`         | All matching rows                    | `table` (array)  |
| `:FirstOrDefault()` | First matching row or `nil`          | `table` / `nil`  |
| `:Count()`          | Number of matching rows              | `number`         |
| `:Any()`            | Does at least one matching row exist?| `boolean`        |

---

## Relations

### HasMany (one-to-many)
```lua
-- Player HasMany Vehicles (vehicles.owner = players.identifier)
relations = {
    vehicles = {
        type         = 'HasMany',
        model        = 'Vehicle',      -- registered model name
        foreignKey   = 'owner',        -- column on the child table
        principalKey = 'identifier',   -- column on the parent table
    },
}
```

### HasOne (one-to-one)
```lua
license = {
    type         = 'HasOne',
    model        = 'License',
    foreignKey   = 'player_id',
    principalKey = 'identifier',
},
```

### BelongsTo (many-to-one)
```lua
-- Vehicle BelongsTo Player
relations = {
    player = {
        type         = 'BelongsTo',
        model        = 'Player',
        foreignKey   = 'owner',        -- column on this table
        principalKey = 'identifier',   -- column on the related table
    },
}
```

### BelongsToMany (many-to-many, via pivot table)
```lua
-- Player BelongsToMany Gang via player_gangs
gangs = {
    type         = 'BelongsToMany',
    model        = 'Gang',
    pivotTable   = 'player_gangs',
    foreignKey   = 'player_id',    -- pivot column → parent
    relatedKey   = 'gang_id',      -- pivot column → related
    principalKey = 'identifier',   -- parent PK
},
```

---

## Validation

Validation runs automatically on `Add()` and `SaveChanges()`.

```lua
fields = {
    name  = { type = 'string', required = true, maxLength = 50, minLength = 2 },
    email = { type = 'string', required = true },
    age   = { type = 'int' },
}
```

| Rule        | Type     | Description                     |
|-------------|----------|---------------------------------|
| `required`  | bool     | Cannot be nil or empty          |
| `maxLength` | number   | Maximum length (strings only)   |
| `minLength` | number   | Minimum length (strings only)   |

---

## Schema / Migrations — Available types

| Lua type   | SQL type       |
|------------|----------------|
| `string`   | `VARCHAR(255)` |
| `text`     | `TEXT`         |
| `int`      | `INT`          |
| `bigint`   | `BIGINT`       |
| `float`    | `FLOAT`        |
| `bool`     | `TINYINT(1)`   |
| `datetime` | `DATETIME`     |
| `json`     | `JSON`         |

Extra column options:
```lua
identifier = {
    type          = 'string',
    length        = 60,        -- overrides VARCHAR(255)
    primaryKey    = true,
    autoIncrement = true,      -- for INT primary keys
    nullable      = false,     -- NOT NULL
    default       = 'civilian' -- DEFAULT value
}
```

---

## Tips

- All DB calls MUST be inside a `Citizen.CreateThread` or `AddEventHandler`
- Always use `Citizen.Await()` to wait for results
- Register models in a separate `context.lua` file that loads first
- Naming your context after your resource makes `/FiveORM migrate` easier
- Each migration name must be unique within a context