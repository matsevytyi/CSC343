DROP TABLE IF EXISTS Q4 CASCADE;

CREATE TABLE Q4(
    album_id BIGINT NOT NULL PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    record_sessions_number INT NOT NULL,
    diff_players_count INT NOT NULL
);
-- diff_players_count once for each player

--Unique record sessions for one track
DROP VIEW IF EXISTS UniqueTrackSessions CASCADE;

CREATE VIEW UniqueTrackSessions AS

SELECT track_id, count(DISTINCT session_id) as track_ses_amnt
FROM Segment NATURAL JOIN TrackSegmentRelation
GROUP BY track_id
ORDER BY track_id
;

--Unique record sessions for each album
DROP VIEW IF EXISTS UniqueAlbumSessions CASCADE;

CREATE VIEW UniqueAlbumSessions AS
SELECT A.album_id, sum(B.track_ses_amnt) as record_sessions_number
FROM TrackAlbumRelation A LEFT JOIN UniqueTrackSessions B
ON A.track_id = B.track_id
GROUP by A.album_id
ORDER by A.album_id
;

--Unique players from each band in each session
DROP VIEW IF EXISTS BandSessionPlayers CASCADE;

CREATE VIEW BandSessionPlayers AS
SELECT SB.session_id, BM.member_id as player_id
FROM Bandmembership BM JOIN SessionBands SB
ON BM.band_id = SB.band_id
;

--Unique players from each band and solo in each track
DROP VIEW IF EXISTS UniqueTrackPlayers CASCADE;

CREATE VIEW UniqueTrackPlayers AS
SELECT DISTINCT player_id, track_id
FROM 
    (SELECT * 
    FROM SessionPerson
    UNION
    SELECT * 
    FROM BandSessionPlayers) 
    AllPlayers
JOIN 
    (SELECT * 
    FROM Segment 
    NATURAL JOIN TrackSegmentRelation)
    SegmentxTrack
ON AllPlayers.session_id = SegmentxTrack.session_id
GROUP BY player_id, track_id
ORDER BY track_id
;

--Unique players participation in each album
DROP VIEW IF EXISTS UniqueAlbumPlayers CASCADE;

CREATE VIEW UniqueAlbumPlayers AS
SELECT TAR.album_id, count(DISTINCT player_id) as diff_players_count
FROM UniqueTrackPlayers UTP
JOIN TrackAlbumRelation TAR
ON UTP.track_id = TAR.track_id
GROUP BY TAR.album_id
;

DROP VIEW IF EXISTS Answer CASCADE;

CREATE VIEW Answer AS
SELECT A.album_id, A.name, B.record_sessions_number, B.diff_players_count
FROM Album A JOIN 
    (UniqueAlbumPlayers 
    NATURAL JOIN UniqueAlbumSessions) 
    B 
ON A.album_id = B.album_id
;

INSERT INTO Q4
SELECT * 
FROM Answer
;