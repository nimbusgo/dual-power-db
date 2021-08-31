const dotenv = require('dotenv');
dotenv.config()

import { migrate, MigrateDBConfig } from "postgres-migrations";
const pg = require('postgres')

async function run() {

    const dbName = process.env.DATABASE || "dual-power";

    const dbConfig: MigrateDBConfig = {
        // connectionString: process.env.DATABASE_URL || "postgres:///decoded"
        database: dbName,
        user: process.env.DATABASE_USER || "postgres",
        password: process.env.DATABASE_PASS || "",
        host: process.env.DATABASE_HOST || "localhost",
        port: 5432,
        ensureDatabaseExists: true
    }
    if (dbName == "dual-power"){
        await migrate(dbConfig, "./migrations")
    } else {
        const dbConfig = {
            database: dbName,
            user: process.env.DATABASE_USER ,
            password: process.env.DATABASE_PASS,
            host: process.env.DATABASE_HOST,
            port: 5432,
          }
      const client = new pg.Client(dbConfig) // or a Pool, or a PoolClient
      await client.connect()
      try {
        await migrate({client}, "migrations")
      } finally {
        await client.end()
      }
    }

}

run();