import { Pool } from 'pg';
import { drizzle } from 'drizzle-orm/node-postgres';
// import { migrate } from 'drizzle-orm/node-postgres/migrator';
// import path from 'path';


const pool = new Pool({
    connectionString: process.env.DB_URL
});


export const initDb =  async () =>
{
    try
    {
        console.log("Database intialized...");
        // console.log('Installing pgvector extension...');
        // await pool.query('CREATE EXTENSION IF NOT EXISTS vector');
        // console.log('pgvector extension installed successfully');

        // console.log('Running database migrations...');
        // await migrate(db, { migrationsFolder: path.join(__dirname, '../../drizzle') });
        // console.log('Database migrations completed successfully');
    }
    catch (error: any)
    {
        console.error("Database initialization failed: ", error);
        throw error;
    }
}

export const db = drizzle(pool);