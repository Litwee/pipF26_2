-- =============================================================================
-- Class survey schema
-- Source: class_dataset.csv (one survey response per student)
--
-- CSV columns map as follows:
--   netid, name, school_year, intro_programming,
--   skill_programming, skill_data_stats, skill_frontend_design, skill_business_pitch
--     -> students
--   tools (semicolon-separated)            -> tools + student_tools
--   availability (semicolon-separated)     -> availability_slots + student_availability
--   working_style, interests, semester_goal, submitted_at
--     -> students
--
-- "none yet" in the tools column means the student listed no tools and
-- should have zero rows in student_tools, not a tool named "none yet".
-- =============================================================================

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------------
-- Lookup: programming / data tools a student may know
-- ---------------------------------------------------------------------------
CREATE TABLE tools (
    tool_id     INTEGER PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE
);

INSERT INTO tools (name) VALUES
    ('Python'),
    ('JavaScript'),
    ('SQL'),
    ('Excel'),
    ('R');

-- ---------------------------------------------------------------------------
-- Lookup: weekly time windows a student is available
-- ---------------------------------------------------------------------------
CREATE TABLE availability_slots (
    slot_id     INTEGER PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    day_group   TEXT NOT NULL CHECK (day_group IN ('weekday', 'weekend')),
    time_of_day TEXT NOT NULL CHECK (time_of_day IN ('mornings', 'afternoons', 'evenings'))
);

INSERT INTO availability_slots (name, day_group, time_of_day) VALUES
    ('Weekday mornings',   'weekday', 'mornings'),
    ('Weekday afternoons', 'weekday', 'afternoons'),
    ('Weekday evenings',   'weekday', 'evenings'),
    ('Weekend mornings',   'weekend', 'mornings'),
    ('Weekend afternoons', 'weekend', 'afternoons'),
    ('Weekend evenings',   'weekend', 'evenings');

-- ---------------------------------------------------------------------------
-- One row per student survey response
-- ---------------------------------------------------------------------------
CREATE TABLE students (
    netid                   TEXT PRIMARY KEY,
    name                    TEXT NOT NULL,
    school_year             TEXT NOT NULL
                            CHECK (school_year IN ('Freshman', 'Sophomore', 'Junior', 'Senior')),
    intro_programming       TEXT NOT NULL
                            CHECK (intro_programming IN ('took_it', 'equivalent', 'neither')),
    skill_programming       INTEGER NOT NULL CHECK (skill_programming BETWEEN 1 AND 5),
    skill_data_stats        INTEGER NOT NULL CHECK (skill_data_stats BETWEEN 1 AND 5),
    skill_frontend_design   INTEGER NOT NULL CHECK (skill_frontend_design BETWEEN 1 AND 5),
    skill_business_pitch    INTEGER NOT NULL CHECK (skill_business_pitch BETWEEN 1 AND 5),
    working_style           TEXT,
    interests               TEXT,
    semester_goal           TEXT,
    submitted_at            TEXT NOT NULL  -- ISO-8601 timestamp from the CSV
);

CREATE INDEX idx_students_school_year ON students (school_year);
CREATE INDEX idx_students_intro_programming ON students (intro_programming);

-- ---------------------------------------------------------------------------
-- Many-to-many: which tools each student listed
-- ---------------------------------------------------------------------------
CREATE TABLE student_tools (
    netid    TEXT NOT NULL REFERENCES students (netid) ON DELETE CASCADE,
    tool_id  INTEGER NOT NULL REFERENCES tools (tool_id) ON DELETE RESTRICT,
    PRIMARY KEY (netid, tool_id)
);

CREATE INDEX idx_student_tools_tool_id ON student_tools (tool_id);

-- ---------------------------------------------------------------------------
-- Many-to-many: which time windows each student is available
-- ---------------------------------------------------------------------------
CREATE TABLE student_availability (
    netid    TEXT NOT NULL REFERENCES students (netid) ON DELETE CASCADE,
    slot_id  INTEGER NOT NULL REFERENCES availability_slots (slot_id) ON DELETE RESTRICT,
    PRIMARY KEY (netid, slot_id)
);

CREATE INDEX idx_student_availability_slot_id ON student_availability (slot_id);
