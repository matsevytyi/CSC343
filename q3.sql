-- Step 1: Drop tables and views if they exist
DROP TABLE IF EXISTS Q3 CASCADE;

DROP VIEW IF EXISTS SessionSegmentLength, SessionWithMaxTotalLength, individualsForLongestSession, bandMembersForLongestSession CASCADE;

-- Step 2: Create a new table 'Q3' to store person details
CREATE TABLE Q3 (
    person_id INT NOT NULL,
    name VARCHAR(255) NOT NULL
);

-- Step 3: Create a view 'SessionSegmentLength' to calculate the total length of segments per session
CREATE OR REPLACE VIEW SessionSegmentLength AS (
    SELECT session_id, SUM(length) AS total_session_length
    FROM Segment
    GROUP BY session_id
);

-- Step 4: Create a view 'SessionWithMaxTotalLength' to identify the session(s) with the longest total length
CREATE OR REPLACE VIEW SessionWithMaxTotalLength AS (
    SELECT session_id 
    FROM SessionSegmentLength
    WHERE total_session_length = (
        SELECT MAX(total_session_length)
        FROM SessionSegmentLength
    )
);

-- Step 5: Create a view 'individualsForLongestSession' to get individual players for the longest session
CREATE OR REPLACE VIEW individualsForLongestSession as (
    SELECT player_id as person_id
    FROM SessionPerson 
    WHERE session_id IN (SELECT session_id FROM SessionWithMaxTotalLength)
);


-- Step 6: Create a view 'bandsForLongestSession' to get the bands that played in the longest session
CREATE OR REPLACE VIEW bandsForLongestSession AS
    SELECT band_id
    FROM SessionBands 
    WHERE session_id IN (SELECT session_id FROM SessionWithMaxTotalLength);


-- Step 7: Create a view 'frontmenForLongestSession' to get frontmen for bands that played in the longest session
CREATE OR REPLACE VIEW frontmenForLongestSession AS (
    SELECT frontman_id AS person_id
    FROM Band 
    WHERE band_id IN (
        SELECT band_id
        FROM bandsForLongestSession
    )
);

-- Step 8: Create a view 'OtherBandMembersForLongestSession' to get other band
-- members (i.e. besides frontman) in the longest session
CREATE OR REPLACE VIEW OtherBandMembersForLongestSession AS (
    SELECT member_id AS person_id
    FROM BandMembership 
    WHERE band_id IN (
        SELECT band_id
        FROM bandsForLongestSession
    )
);

-- Step 9: Create a view 'peopleInLongestSessionDetails' to combine frontmen,
-- individuals, and other band members which all played in the longest session.
CREATE OR REPLACE VIEW peopleInLongestSessionDetails AS (
    SELECT person_id, name
    FROM Person 
    NATURAL JOIN (
        SELECT * FROM frontmenForLongestSession
        UNION 
        SELECT * FROM individualsForLongestSession
        UNION 
        SELECT * FROM OtherBandMembersForLongestSession
    ) AS combinedSessions
);

-- Step 10: Insert the details of people in the longest session into table 'Q3'
INSERT INTO Q3
SELECT *
FROM peopleInLongestSessionDetails;
