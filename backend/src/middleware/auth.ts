import { Request, Response, NextFunction } from 'express';
import dotenv from 'dotenv';
import path from 'path';
import { UUID } from 'crypto';
import jwt from 'jsonwebtoken';
import { eq } from 'drizzle-orm';

import { db } from '../utils/db';
import { users } from '../models/user';

dotenv.config({path: path.resolve(__dirname, "../../.env")});


export interface AuthRequest extends Request
{
    user?: UUID;
    token?: string;
}


export async function auth (req: AuthRequest, res: Response, next: NextFunction)
{
    try
    {
        const token = req.header('x-auth-token');

        if (!token)
        {
            res.status(400).json({error: "no auth token, access denied"});
            return;
        }

        const verified = jwt.verify(token, process.env.JWT_KEY!);

        if (!verified)
        {
            res.status(401).json({error: "invalid token, access denied"});
            return;
        }

        const verifiedToken = verified as {id: UUID};

        const [user] = await db.select().from(users).where(eq(users.id, verifiedToken.id));

        if (!user)
        {
            res.status(401).json({error: "user not found"});
            return;
        }

        req.user = verifiedToken.id;
        req.token = token;

        next();
    }
    catch (error: any)
    {
        res.status(500).json({error: error.message});
    }
}