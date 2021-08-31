const dotenv = require('dotenv');
const result = dotenv.config()

const express = require( "express" );
import { postgraphile } from "postgraphile";

const app = express();

app.use(
  postgraphile(
    process.env.DATABASE_URL || "postgres://user:pass@host:5432/dbname",
    ["app_public", "app_hidden"],
    {
      graphiql: true,
      enhanceGraphiql: true,
    }
  )
);

app.listen(process.env.PORT || 5000);