import { db } from './db';
import { tasks, Task } from '../models/task';
import { sql, eq, and, between } from 'drizzle-orm';


export interface TemporalTasks {
    ring1: Task[];
    ring2: Task[];
    ring3: Task[];
}


const getDateRange = (date: Date) => 
{
    const start = new Date(date);
    start.setHours(0, 0, 0, 0);

    const end = new Date(date);
    end.setHours(23, 59, 59, 999);

    return { start, end };
};


export async function getTemporalRings(uid: string): Promise<TemporalTasks>
{
    try 
    {
        const now = new Date();
        const nowIsoString = now.toISOString();
        
        const nowTimeString = now.toTimeString().split(' ')[0];
    
    
        const todayRange = getDateRange(now);
    
        const yesterday = new Date(now); yesterday.setDate(now.getDate() - 1);
        const twoDaysAgo = new Date(now); twoDaysAgo.setDate(now.getDate() - 2);
        const threeDaysAgo = new Date(now); threeDaysAgo.setDate(now.getDate() - 3);
    
        const oneWeekAgo = new Date(now); oneWeekAgo.setDate(now.getDate() - 7);
        const twoWeeksAgo = new Date(now); twoWeeksAgo.setDate(now.getDate() - 14);
        const threeWeeksAgo = new Date(now); threeWeeksAgo.setDate(now.getDate() - 21);
    
    
        // Set 1: Today
        const querySet1 = db.select()
            .from(tasks)
            .where(and(
                eq(tasks.uid, uid),
                between(tasks.dueAt, todayRange.start, todayRange.end)
            ))
            .orderBy(sql`ABS(EXTRACT(EPOCH FROM (${tasks.dueAt} - ${nowIsoString}::timestamptz)))`)
            .limit(3);
    
    
        // Set 2: Previous 3 Unique Days
        const createSet2Query = (targetDate: Date) => 
        {
            const range = getDateRange(targetDate);
    
            return db.select()
                .from(tasks)
                .where(and(
                    eq(tasks.uid, uid),
                    between(tasks.dueAt, range.start, range.end)
                ))
                .orderBy(sql`ABS(EXTRACT(EPOCH FROM (${tasks.dueAt}::time - ${nowTimeString}::time)))`)
                .limit(1);
        };
        const querySet2_yesterday = createSet2Query(yesterday);
        const querySet2_twoDaysAgo = createSet2Query(twoDaysAgo);
        const querySet2_threeDaysAgo = createSet2Query(threeDaysAgo);
    
    
        // Set 3: Same Weekday, Previous 3 Weeks
        const createSet3Query = (targetDate: Date) => 
        {
            const range = getDateRange(targetDate);
            
            return db.select()
                .from(tasks)
                .where(and(
                    eq(tasks.uid, uid),
                    between(tasks.dueAt, range.start, range.end)
                ))
                .orderBy(sql`ABS(EXTRACT(EPOCH FROM (${tasks.dueAt}::time - ${nowTimeString}::time)))`)
                .limit(1);
        };
        const querySet3_oneWeekAgo = createSet3Query(oneWeekAgo);
        const querySet3_twoWeeksAgo = createSet3Query(twoWeeksAgo);
        const querySet3_threeWeeksAgo = createSet3Query(threeWeeksAgo);


        // Execute all queries in parallel
        const [
            set1Result,
            set2YesterdayResult,
            set2TwoDaysAgoResult,
            set2ThreeDaysAgoResult,
            set3OneWeekAgoResult,
            set3TwoWeeksAgoResult,
            set3ThreeWeeksAgoResult,
        ] = await Promise.all([
            querySet1,
            querySet2_yesterday,
            querySet2_twoDaysAgo,
            querySet2_threeDaysAgo,
            querySet3_oneWeekAgo,
            querySet3_twoWeeksAgo,
            querySet3_threeWeeksAgo,
        ]);


        // Combine results for Set 2 and Set 3
        const set2Result = [
            ...set2YesterdayResult,
            ...set2TwoDaysAgoResult,
            ...set2ThreeDaysAgoResult
        ];
        const set3Result = [
            ...set3OneWeekAgoResult,
            ...set3TwoWeeksAgoResult,
            ...set3ThreeWeeksAgoResult
        ];

        console.log(`Structured Temporal Tasks: Set1(${set1Result.length}), Set2(${set2Result.length}), Set3(${set3Result.length})`);

        return {
            ring1: set1Result,
            ring2: set2Result,
            ring3: set3Result,
        };

    } 
    catch (error) 
    {
        console.error("Error fetching structured temporal tasks:", error);
        return {
            ring1: [],
            ring2: [],
            ring3: [],
        };
    }
}
