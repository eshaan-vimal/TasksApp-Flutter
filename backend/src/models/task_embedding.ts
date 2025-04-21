import { pgTable, uuid, vector, timestamp } from "drizzle-orm/pg-core";

import { users } from "./user";
import { tasks } from "./task";


export const taskEmbeddings = pgTable(
    'task_embeddings',
    {
        id: uuid("task_id").primaryKey().references(() => tasks.id, { onDelete: 'cascade' }),
        embedding: vector("embedding", { dimensions: 384 }).notNull(),
        uid: uuid('uuid').notNull().references(() => users.id, {onDelete: 'cascade'}),
        createdAt: timestamp("created_at").defaultNow(),
    },
);

export type TaskEmbedding = typeof taskEmbeddings.$inferSelect;
export type NewTaskEmbedding = typeof taskEmbeddings.$inferInsert;
