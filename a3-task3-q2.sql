-- For each person in the database, report their ID and the number of recording sessions they have played at.

-- Include everyone, even if they are a manager or engineer, and even if they
-- never played at any sessions.

-- Map all individuals who played in a session. Note that this includes people
-- who have never played in a session, but their session_id is null.
CREATE OR REPLACE VIEW IndividualSessions as 
    SELECT person_id, session_id
    FROM (
        SessionPerson RIGHT JOIN Person ON person_id = player_id
    )
;


-- Map all members of a band in which the band played in a session.
CREATE OR REPLACE VIEW FrontManSessions as 
    SELECT frontman_id as person_id, session_id 
    FROM (
        Band NATURAL JOIN 
        (
            SELECT session_id, band_id 
            FROM SessionBands
        )
    )

;
CREATE OR REPLACE VIEW OtherBandMemberSessions as 
    SELECT member_id as person_id, session_id
    FROM (
        BandMembership NATURAL JOIN 
        (
            SELECT session_id, band_id 
            FROM SessionBands
        )
    )
;
CREATE OR REPLACE VIEW AllBandMemberSessions as 
    SELECT *
    FROM FrontManSessions UNION OtherBandMemberSessions
;


-- The final query which maps ALL persons to the number of sessions they played
-- at.
CREATE OR REPLACE VIEW PersonSessionCount as 
    SELECT person_id, COUNT(DISTINCT session_id)
    FROM 
    (IndividualSessions UNION AllBandMemberSessions)
;