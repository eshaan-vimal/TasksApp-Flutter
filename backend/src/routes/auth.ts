import { Router, Request } from 'express';
import dotenv from 'dotenv';
import path from 'path';
import { eq } from 'drizzle-orm';
import brcyptjs from 'bcryptjs';
import jwt from 'jsonwebtoken';

import { db } from '../utils/db';
import { NewUser, users } from '../models/user';
import { AuthRequest, auth } from '../middleware/auth';

dotenv.config({path: path.resolve(__dirname, "../../.env")});


const authRouter = Router();


interface SignupBody
{
    name: string,
    email: string,
    password: string,
}

interface LoginBody
{
    email: string,
    password: string,
}


authRouter.post('/signup', async (req: Request<{}, {}, SignupBody>, res) => 
{
    try
    {
        const {name, email, password} = req.body;

        const [existingUser] = await db.select().from(users).where(eq(users.email, email));

        if (existingUser)
        {
            res.status(400).json({msg: "email already registered"});
            return;
        }

        const hashedPassword = await brcyptjs.hash(password, 10);

        const newUser: NewUser = {
            name,
            email,
            password: hashedPassword,
        };

        const [user] = await db.insert(users).values(newUser).returning();
        res.status(201).json(user);
    }
    catch (error: any)
    {
        res.status(500).json({error: error.message});
    }
});


authRouter.post('/login', async (req: Request<{},{},LoginBody>, res) => 
{
    try
    {
        const {email, password} = req.body;

        const [user] = await db.select().from(users).where(eq(users.email, email));

        if (!user)
        {
            res.status(400).json({error: "email not registered"});
            return;
        }

        const isValid = await brcyptjs.compare(password, user.password);

        if (!isValid)
        {
            res.status(401).json({error: "invalid password"});
            return;
        }

        const token = jwt.sign({id: user.id}, process.env.JWT_KEY!);

        res.json({token, ...user});
    }
    catch (error: any)
    {
        res.status(500).json({error: error.message});
    }
});


authRouter.get('/', auth, async (req: AuthRequest, res) => 
{
    try
    {
        if (!req.user)
        {
            res.status(401).json({error: "user not found"});
            return;
        }
    
        const [user] = await db.select().from(users).where(eq(users.id, req.user));
    
        res.status(200).json({token: req.token , ...user});
    }
    catch (error: any)
    {
        res.status(500).json({error: error.message});
    }
});


// authRouter.post('/istokenvalid', async (req, res) => 
// {
//     try
//     {
//         const token = req.header('x-auth-token');

//         if (!token)
//         {
//             res.status(400).json(false);
//             return;
//         }

//         const verified = jwt.verify(token, process.env.JWT_KEY!);

//         if (!verified)
//         {
//             res.status(401).json(false);
//             return;
//         }

//         const verifiedToken = verified as {id: string};

//         const [user] = await db.select().from(users).where(eq(users.id, verifiedToken.id));

//         res.status(200).json(true);
//     }
//     catch (error)
//     {
//         res.status(500).json(false);
//     }
// });


export default authRouter;