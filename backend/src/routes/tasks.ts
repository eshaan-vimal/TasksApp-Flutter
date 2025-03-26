import { Router } from 'express';
import { eq } from 'drizzle-orm';

import { auth, AuthRequest } from '../middleware/auth';
import { NewTask, tasks } from '../models/task';
import { db } from '../utils/db';


const taskRouter = Router();


taskRouter.post('/', auth, async (req: AuthRequest, res) => 
{
    try
    {
        if (!req.user)
        {
            res.status(401).json({error: "user not found"});
            return;
        }

        req.body = {...req.body, dueAt: new Date(req.body.dueAt), uid: req.user};
        const newTask: NewTask = req.body;

        const [task] = await db.insert(tasks).values(newTask).returning();
        res.status(201).json(task);
    }
    catch (error: any)
    {
        res.status(500).json({error: error.message});
    }
});


taskRouter.get('/', auth, async (req: AuthRequest, res) => 
{
    try
    {
        if (!req.user)
        {
            res.status(401).json({error: "user not found"});
            return;
        }

        const allTasks = await db.select().from(tasks).where(eq(tasks.uid, req.user));

        res.status(200).json(allTasks);
    }
    catch (error: any)
    {
        res.status(500).json({error: error.message});
    }
});


taskRouter.delete('/', auth, async (req: AuthRequest, res) =>
{
    try
    {
        if (!req.user)
        {
            res.status(401).json({error: "user not found"});
            return;
        }
    
        const {taskId}: {taskId: string} = req.body;
        await db.delete(tasks).where(eq(tasks.id, taskId));
    
        res.status(200).json("task deleted successfully");
    }
    catch (error: any)
    {
        res.status(500).json({error: error.message});
    }
});


taskRouter.post('/sync', auth, async (req: AuthRequest, res) =>
{
    try
    {
        if (!req.user)
        {
            res.status(401).json({error: "User not found"});
            return;
        }
    
        const unsyncedTasks = req.body;
        const unsyncedTasksList: NewTask[] = [];
    
        for (let unsyncedTask of unsyncedTasks)
        {
            const {id, ...rest} = unsyncedTask;

            unsyncedTask = {
                ...rest, 
                uid: req.user,
                dueAt: new Date(unsyncedTask.dueAt), 
                createdAt: new Date(unsyncedTask.createdAt),
                updatedAt: new Date(unsyncedTask.updatedAt),
            }
            unsyncedTasksList.push(unsyncedTask);
        }

        const syncedTasks = await db.insert(tasks).values(unsyncedTasksList).returning();
        res.status(201).json(syncedTasks);
    }
    catch (error: any)
    {
        res.status(500).json({error: error.message});
    }
});


export default taskRouter;