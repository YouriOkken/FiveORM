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
