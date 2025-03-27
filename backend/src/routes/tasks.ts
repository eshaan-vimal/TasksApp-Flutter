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

        console.log(req.body);

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


taskRouter.post('/sync/update', auth, async (req: AuthRequest, res) =>
{
    try
    {
        if (!req.user)
        {
            res.status(401).json({error: "User not found"});
            return;
        }
    
        const updatedTasks = req.body;
        const updatedTasksList: NewTask[] = [];
    
        for (let updatedTask of updatedTasks)
        {
            const {id, pendingUpdate, pendingDelete, ...rest} = updatedTask;

            console.log(updatedTask);

            updatedTask = {
                ...rest, 
                uid: req.user,
                dueAt: new Date(updatedTask.dueAt), 
                createdAt: new Date(updatedTask.createdAt),
                updatedAt: new Date(updatedTask.updatedAt),
            }

            const [syncedUpdatedTask] = await db.insert(tasks).values(updatedTask).onConflictDoUpdate({
                target: tasks.id,
                set: {
                    title: updatedTask.title,
                    description: updatedTask.description,
                    hexColour: updatedTask.hexColour,
                    dueAt: updatedTask.dueAt,
                    updatedAt: updatedTask.updatedAt,
                },
            }).returning()

            updatedTasksList.push(syncedUpdatedTask);
        }

        res.status(201).json(updatedTasksList);
    }
    catch (error: any)
    {
        res.status(500).json({error: error.message});
    }
});


taskRouter.delete('/sync/delete', auth, async (req: AuthRequest, res) =>
{
    try
    {
        if (!req.user)
        {
            res.status(401).json({error: "User not found"});
            return;
        }
    
        const deletedTasks = req.body;
        const deletedTaskIds = [];
    
        for (let deletedTask of deletedTasks)
        {
            await db.delete(tasks).where(eq(tasks.id, deletedTask.id));
    
            deletedTaskIds.push(deletedTask.id);
        }
    
        res.status(201).json(deletedTaskIds);
    }
    catch (error: any)
    {
        res.status(500).json({error: error.message});
    }
});


export default taskRouter;