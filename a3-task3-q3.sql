-- Find the recording session that produced the greatest total number of seconds of recording segments. 

-- Report the ID and name of everyone who played at that session, whether as
-- part of a band or in a solo capacity.

-- Sums the length of all segments per session.
CREATE OR REPLACE VIEW SessionSegmentLength as (
    SELECT session_id, SUM(length) as total_session_length
    FROM Segment
    GROUP BY session_id
);

-- The session_id (can be multiple) with the longest total length.
CREATE OR REPLACE VIEW SessionWithMaxTotalLength as (
    SELECT session_id 
    FROM SessionSegmentLength
    WHERE total_session_length = (
        SELECT MAX(total_session_length)
        FROM SessionSegmentLength
    )
);

-- We first have to get whoever booked that session since it is assumed that
-- they must have played in that session.
CREATE OR REPLACE VIEW bookerForLongestSession as (
    SELECT booker_id as player_id
    FROM Sessions 
    WHERE session_id = SessionWithMaxTotalLength
);

-- Then, we also have to get all individual players for that session.
CREATE OR REPLACE VIEW individualsForLongestSession as (
    SELECT player_id
    FROM SessionPerson 
    WHERE session_id = SessionWithMaxTotalLength
);

-- Then, we have to get the band members that are in the session.
CREATE OR REPLACE VIEW bandMembersForLongestSession as (
    SELECT player_id
    FROM SessionPerson 
    WHERE session_id = SessionWithMaxTotalLength
);

-- The final query for the details of people in the longest session.
CREATE OR REPLACE VIEW peopleInLongestSessionDetails as (
    SELECT person_id, name
    FROM Person NATURAL JOIN (
        bookerForLongestSession
        UNION 
        individualsForLongestSession
        UNION 
        bandMembersForLongestSession
    )
);
