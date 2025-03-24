import { defineConfig } from 'drizzle-kit';
import dotenv from 'dotenv';
import path from 'path';


dotenv.config({path: path.resolve(__dirname, "../.env")});

// console.log(process.env.DB_PASSWORD);
// console.log(process.env.DB_HOST);
// console.log(process.env.DB_NAME);
// console.log(process.env.DB_USER);
// console.log(process.env.DB_PORT);


export default defineConfig({
    dialect: "postgresql",
    schema: "./models/*.ts",
    out: "./drizzle",
    dbCredentials: {
        host: "localhost",
        port: Number(process.env.DB_HOST_PORT) || 5432,
        database: process.env.DB_NAME!,
        user: process.env.DB_USER!,
        password: process.env.DB_PASSWORD!,
        ssl: false,
    },
});