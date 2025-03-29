import { Router } from 'express';
import { eq } from 'drizzle-orm';
import { GoogleGenAI } from '@google/genai';

import { auth, AuthRequest } from '../middleware/auth';
import { NewTask, tasks } from '../models/task';
import { db } from '../utils/db';


const taskRouter = Router();
const ai = new GoogleGenAI({apiKey: process.env.GENAI_KEY});


taskRouter.post('/compose', auth, async (req: AuthRequest, res) =>
{
    try
    {
        if (!req.user)
        {
            res.status(401).json({error: "User not found"});
        }

        const { title, description } = req.body;

        const prompt = description ? 
            `I am curating a list of tasks that i need to perform. I need you to rephrase the following task description for the task "${title}". Respond only with the rephrased description in text format and nothing else."` :
            `I am curating a list of tasks that i need to perform. I need you to write a clear, concise description in upto 2 lines max for this task: "${title}". Respond only with the rephrased description in text format and nothing else.`;

        const aiResponse = await ai.models.generateContent({
            model: 'gemini-2.0-flash',
            contents: [{
                "parts":[{"text": prompt}]
            }],
        });

        if (!aiResponse.text)
        {
            res.status(500).json({error: "AI is busy"});
        }

        res.status(200).json({description: aiResponse.text});
    }
    catch (error: any)
    {
        res.status(500).json({error: "Server Error: Smart compose failed"});
    }
});


taskRouter.post('/', auth, async (req: AuthRequest, res) => 
{
    try
    {
        if (!req.user)
        {
            res.status(401).json({error: "User not found"});
            return;
        }

        req.body = {...req.body, dueAt: new Date(req.body.dueAt), uid: req.user};
        const newTask: NewTask = req.body;

        const [task] = await db.insert(tasks).values(newTask).returning();
        res.status(201).json(task);
    }
    catch (error: any)
    {
        res.status(500).json({error: "Server Error: Failed to create new task"});
    }
});


taskRouter.get('/', auth, async (req: AuthRequest, res) => 
{
    try
    {
        if (!req.user)
        {
            res.status(401).json({error: "User not found"});
            return;
        }

        const allTasks = await db.select().from(tasks).where(eq(tasks.uid, req.user));

        res.status(200).json(allTasks);
    }
    catch (error: any)
    {
        res.status(500).json({error: "Server Error: Failed to fetch tasks"});
    }
});


taskRouter.delete('/', auth, async (req: AuthRequest, res) =>
{
    try
    {
        if (!req.user)
        {
            res.status(401).json({error: "User not found"});
            return;
        }
    
        const {taskId}: {taskId: string} = req.body;
        await db.delete(tasks).where(eq(tasks.id, taskId));
    
        res.status(200).json("Task deleted successfully");
    }
    catch (error: any)
    {
        res.status(500).json({error: "Server Error: Failed to delete task"});
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
        res.status(500).json({error: "Server Error: Failed to sync locally updated tasks"});
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
        res.status(500).json({error: "Server Error: Failed to sync locally deleted tasks"});
    }
});


export default taskRouter;