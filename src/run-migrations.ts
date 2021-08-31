const dotenv = require('dotenv');
dotenv.config()

import { migrate, MigrateDBConfig } from "postgres-migrations";
// import { MigrateDBConfig } from "postgres-migrations/dist/types"

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

    // await createDb(dbName, {
    //     ...dbConfig,
    //     defaultDatabase: "postgres", // defaults to "postgres"
    // })
    await migrate(dbConfig, "./migrations")

}

run();