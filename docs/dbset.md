# Lua OOP via metatables

`DbSet.New("players")` maakt een nieuw leeg object aan met alleen de data die je meegeeft:

```lua
{ _table = "players" }  -- verder niks
```

Dat object heeft zelf geen enkele method. Maar via `setmetatable` koppel je `DbSet` als z'n parent:

```lua
return setmetatable({ _table = tableName }, DbSet)
```

En `DbSet.__index = DbSet` zorgt dat Lua bij een missende method ook echt **in** DbSet gaat zoeken.

Dus als je dit doet:

```lua
Player:ToListAsync()
```

Gebeurt dit:
1. Zoek `ToListAsync` op `Player` → niet gevonden
2. Kijk in de gekoppelde parent (`DbSet`) → gevonden ✓

---

Het is hetzelfde als C# klassen, maar dan handmatig:

| Lua | C# |
|---|---|
| `DbSet.New("players")` | `new DbSet("players")` |
| `setmetatable(..., DbSet)` | `: DbSet` (overerving) |
| `DbSet.__index = DbSet` | class definitie |
| `self._table` | `this._table` |

Het object heeft de **data**, de class heeft de **methods**.