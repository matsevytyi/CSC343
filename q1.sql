DROP TABLE IF EXISTS Q1 CASCADE;

--for each studio
CREATE TABLE Q1 (
    studio_id BIGINT NOT NULL,
    current_manager_id INT NOT NULL,
    name VARCHAR(255),
    albums_contibuted INT NOT NULL
);

-- select current_manager_id, name and studio_id
DROP VIEW IF EXISTS CurrentManagerData CASCADE;

CREATE VIEW CurrentManagerData AS
WITH RankedManagers AS (
    SELECT
        MH.studio_id,
        MH.manager_id AS current_manager_id,
        P.name,
        MH.employment_start_date,
        ROW_NUMBER() OVER (PARTITION BY MH.studio_id ORDER BY MH.employment_start_date DESC) AS rnk
    FROM ManagersHistory MH
    LEFT JOIN Person P ON MH.manager_id = P.person_id
)
SELECT studio_id, current_manager_id, name, employment_start_date
FROM RankedManagers
WHERE rnk = 1
;

--all recording segments of each studio
DROP VIEW IF EXISTS StudioSegments CASCADE;

CREATE VIEW StudioSegments AS
SELECT segment_id, studio_id
FROM
Segment NATURAL JOIN MySessions
;

--all recording tracks of each studio
DROP VIEW IF EXISTS StudioTracks CASCADE;

CREATE VIEW StudioTracks AS
SELECT track_id, studio_id
FROM
StudioSegments NATURAL JOIN TrackSegmentRelation
;


--all recording albums of each studio
DROP VIEW IF EXISTS StudioAlbums CASCADE;

CREATE VIEW StudioAlbums AS
SELECT DISTINCT album_id, studio_id
FROM
StudioTracks NATURAL JOIN Album
;

--answer
DROP VIEW IF EXISTS Answer CASCADE;

CREATE VIEW Answer AS
SELECT studio_id, current_manager_id, name, count(album_id) as albums_contibuted
FROM
StudioAlbums NATURAL JOIN CurrentManagerData
GROUP BY studio_id, current_manager_id, name
ORDER BY studio_id
;

INSERT INTO Q1
SELECT *
FROM Answer
;