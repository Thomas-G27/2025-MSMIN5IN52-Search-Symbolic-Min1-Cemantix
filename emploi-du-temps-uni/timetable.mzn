% University Timetabling Model in MiniZinc
% This model assigns time slots and rooms to courses/exams
% Constraints: no overlaps for teachers/rooms, capacity, etc.

include "globals.mzn";

% Parameters (to be defined in data file)
int: num_events;  % Number of courses/exams
int: num_slots;   % Number of time slots (e.g., 5 days * 8 hours = 40)
int: num_rooms;   % Number of rooms
int: num_teachers; % Number of teachers

set of int: EVENTS = 1..num_events;
set of int: SLOTS = 1..num_slots;
set of int: ROOMS = 1..num_rooms;
set of int: TEACHERS = 1..num_teachers;

% Event data
array[EVENTS] of int: event_teacher;  % Teacher assigned to each event
array[EVENTS] of int: event_duration; % Duration in slots (assume 1 for simplicity)
array[EVENTS] of int: event_students; % Number of students

% Room data
array[ROOMS] of int: room_capacity;   % Capacity of each room

% Teacher availability (1 if available, 0 if not)
array[TEACHERS, SLOTS] of 0..1: teacher_available;

% Variables
array[EVENTS] of var SLOTS: event_start;  % Start time slot for each event
array[EVENTS] of var ROOMS: event_room;   % Room assigned to each event

% ensure events fit within available slots
constraint forall(e in EVENTS)(
    event_start[e] + event_duration[e] - 1 <= num_slots
);

% Constraints

% 1. No two events in the same room at overlapping times
constraint forall(i,j in EVENTS where i < j)(
    event_room[i] != event_room[j] 
    \/ event_start[i] + event_duration[i] - 1 < event_start[j]
    \/ event_start[j] + event_duration[j] - 1 < event_start[i]
);

% 2. Teacher conflicts: no two events for same teacher with overlapping times
constraint forall(i,j in EVENTS where i < j /\
                      event_teacher[i] == event_teacher[j])(
    event_start[i] + event_duration[i] - 1 < event_start[j]
    \/ event_start[j] + event_duration[j] - 1 < event_start[i]
);

% 3. Room capacity
constraint forall(e in EVENTS)(
    event_students[e] <= room_capacity[event_room[e]]
);

% 4. Teacher availability across the whole duration
constraint forall(e in EVENTS)(
    forall(k in 0..event_duration[e]-1)(
        teacher_available[event_teacher[e], event_start[e] + k] == 1
    )
);

% 5. Optional: No event starts at invalid slots, but assume all slots are valid

% Objective: For now, just satisfy (find any feasible assignment)
% Later, can add minimize total conflicts or something

% Prefer assigning events to small rooms that still fit the student count.
% Minimize the total capacity used across all events (heuristic).
solve minimize sum(e in EVENTS)(room_capacity[event_room[e]]);

% Output
output [
    "Emploi du temps universitaire:\n" ++
    concat([ "Cours " ++ show(e) ++ ": Enseignant " ++ show(event_teacher[e]) ++
             ", Début " ++ show(event_start[e]) ++ ", Salle " ++ show(event_room[e]) ++ "\n"
             | e in EVENTS ])
];