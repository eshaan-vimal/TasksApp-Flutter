import express from 'express';
import dotenv from 'dotenv';
import path from 'path';

import authRouter from './routes/auth';
import taskRouter from './routes/tasks';

dotenv.config({path: path.resolve(__dirname, "../.env")});


const app = express();

app.use(express.json());
app.use('/auth', authRouter);
app.use('/task', taskRouter);


app.get('/', (req, res) => {
    res.send("hello");
})

app.listen(process.env.PORT, () => {
    console.log("Server started at PORT 8000...");
});