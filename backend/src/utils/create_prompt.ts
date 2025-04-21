import { Task } from '../models/task'; 
import { TemporalTasks } from './temporal_rings';


export function formatTemporalTasks(temporalTasks: TemporalTasks)
{
    const formatList = (label: string, tasks: Task[]) => 
    {
        if (tasks.length === 0) 
        {
            return '';
        }
        
        const taskLines = tasks
            .map(t => `- ${t.title}: ${t.description} (Due: ${t.dueAt instanceof Date ? t.dueAt.toISOString() : 'N/A'}, Card color: ${t.hexColour})`)
            .join('\n');
        return `\n${label}:\n${taskLines}`;
    };


    let formattedString = "### Relevant Past & Upcoming Tasks";
    formattedString += formatList("Today (Closest to Now)", temporalTasks.ring1);
    formattedString += formatList("Previous Days (Closest to This Time)", temporalTasks.ring2);
    formattedString += formatList("Previous Weeks - Same Day (Closest to This Time)", temporalTasks.ring3);
    
    const trimmed = formattedString.trim();
    return trimmed === "### Relevant Past & Upcoming Tasks" ? "No relevant past or upcoming tasks found in temporal rings." : trimmed;
}


export function createPrompt(temporalTasks: TemporalTasks, userTimezone: string)
{
    const formattedTemporalTasks = formatTemporalTasks(temporalTasks);
    const currentTimeContext = `[CURRENT_TIME] ${(new Date()).toISOString()} \n[USER_TIMEZONE] ${userTimezone}`;


    const prompt = `
You are a helpful task suggestion assistant integrated into a Tasks App.
Your goal is to suggest exactly 3 relevant *new* tasks the user might want to create based on their current context and past/upcoming activities.

**Current User Context:**

Time context:
${currentTimeContext}

Tasks context:
${formattedTemporalTasks}

**Instructions:**
1.  Analyze the provided context (current time, date, time block, pending tasks, recent tasks, historical tasks from temporal rings).
2.  Suggest exactly 3 **new** tasks that are highly relevant and likely for the user to perform next or soon. Do not suggest tasks already listed in the context.
3.  For each suggestion, provide:
    * A clear, concise \`title\`.
    * A brief \`description\` (1-2 lines).
    * A suitable \`hexColour\` that the user is likely to choose but also can be somewhat random.
    * A plausible \`dueAt\` time specified in **ISO 8601 format using UTC (ending with 'Z')**. Base the timing logically on the current time and task nature (e.g., suggest tasks for later today, tomorrow morning, etc., relative to the user's ${userTimezone} time).
4.  Generate a user-friendly "hint" text (1 sentence) for each suggestion, explaining *why* it's being suggested (e.g., "Since you often journal in the morning...", "Planning tomorrow might be helpful now...", "Based on your recently completed X...").
5.  If and only if no context is provided, then suggest random tasks you deem fit for the user.

**Output Format:**
Respond **ONLY** with a valid JSON object containing exactly two keys: "tasks" and "hints".
1.  The value for the "tasks" key must be an array containing exactly 3 task suggestion objects: \`[{title, description, hexColour, dueAt}, ...]\`.
2.  The value for the "hints" key must be an array containing exactly 3 corresponding UI hint strings: \`["hint 1", "hint 2", "hint 3"]\`. Ensure the order of hints matches the order of tasks.

**Example JSON Output:**
{
  "tasks": [
    {"title": "Plan tomorrow's schedule", "description": "Outline key tasks and appointments for tomorrow.", "hexColour": "2196F3", "dueAt": "2025-04-22T03:30:00Z"},
    {"title": "Review project feedback", "description": "Go over the feedback received on the recent project submission.", "hexColour": "FF9800", "dueAt": "2025-04-22T05:00:00Z"},
    {"title": "Morning Journaling", "description": "Reflect on yesterday and set intentions for today.", "hexColour": "4CAF50", "dueAt": "2025-04-22T02:30:00Z"}
  ],
  "hints": [
    "It's 1:16 AM (IST), planning for tomorrow might be useful.",
    "You recently completed the project submission, reviewing feedback could be next.",
    "You seem to have a pattern of morning tasks, maybe add journaling?"
  ]
}

**Note: It should be exactly in the above format because I need to JSON.parse it**
`;
    return prompt;
}