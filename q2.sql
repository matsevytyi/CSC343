-- Step 1: Drop table and views if they exist
DROP TABLE IF EXISTS Q2 CASCADE;

DROP VIEW IF EXISTS IndividualSessions, FrontManSessions, OtherBandMemberSessions, AllBandMemberSessions, PersonSessionCount CASCADE;

-- Step 2: Create a new table 'Q2' to store studio session counts
CREATE TABLE Q2 (
    studio_id INT NOT NULL,
    session_count INT NOT NULL
);

-- Step 3: Create a view 'IndividualSessions' to map individuals who played in sessions
CREATE OR REPLACE VIEW IndividualSessions AS 
    SELECT person_id, session_id
    FROM (
        SessionPerson RIGHT JOIN Person ON person_id = player_id
    );

-- Step 4: Create a view 'FrontManSessions' to map frontmen of bands in sessions
CREATE OR REPLACE VIEW FrontManSessions AS 
    SELECT frontman_id AS person_id, session_id 
    FROM (
        Band NATURAL JOIN 
        (
            SELECT session_id, band_id 
            FROM SessionBands
        )
    );

-- Step 5: Create a view 'OtherBandMemberSessions' to map other members of bands in sessions
CREATE OR REPLACE VIEW OtherBandMemberSessions AS 
    SELECT member_id AS person_id, session_id
    FROM (
        BandMembership NATURAL JOIN 
        (
            SELECT session_id, band_id 
            FROM SessionBands
        )
    );

-- Step 6: Create a view 'AllBandMemberSessions' to map all members of bands in sessions
CREATE OR REPLACE VIEW AllBandMemberSessions AS 
    (SELECT * FROM FrontManSessions 
    UNION 
    SELECT * FROM OtherBandMemberSessions);

-- Step 7: Create a view 'PersonSessionCount' to map all persons to the number of sessions they played in
CREATE OR REPLACE VIEW PersonSessionCount AS 
    SELECT CombinedSessions.person_id, COUNT(DISTINCT CombinedSessions.session_id) AS session_count
    FROM 
    (
        SELECT person_id, session_id FROM IndividualSessions 
        UNION 
        SELECT person_id, session_id FROM AllBandMemberSessions
    ) AS CombinedSessions
    GROUP BY CombinedSessions.person_id;

-- Step 8: Insert the session counts for each person into table 'Q2'
INSERT INTO Q2
SELECT *
FROM PersonSessionCount;
