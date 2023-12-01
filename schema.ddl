-- I think to avoid using triggers as per @664 & @742, it is best if we stick
with og_manager_id. Then, if we want to hire a new manager for a studio, it is
enough that we add them to NewManagers table.
CREATE TABLE Studios (
    studio_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    studio_name VARCHAR(255),
    address VARCHAR(255),
    og_manager_id INT,
    FOREIGN KEY (og_manager_id) REFERENCES Manages(manager_id) 
);


-- FOR ENGINEER CONSTRAINT: So what I'm saying is if we create a session, it
must have an engineer that must be in CertificatedEngineers table. But, if that
person is in CertificatedEngineers table, they must already have at least one
certificate. 

-- Looking at the ExtraEngineersPerSession Table, that contains any additional
engineers we have for a session (GO TO THAT TABLE).

-- Now consider our constraint where at least one person must play in a session.
Previously, we said that either a band or a person can book a session. But this
implies that our player_id is a foreign key to 2 tables (impossible).
-- With current implementation, we ASSUME that only one person can book a
session. We also ASSUME that the person who booked the session is gonna play in
the session. If a band wants to book a session, we ASSUME that the person
booking is part of the band (and will play in that session). If a band wants to
book, they must be explicitly added to SessionBands table. If it is an
individual, they must be added to SessionPerson.
CREATE TABLE Sessions (
    session_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    studio_id BIGINT,
    start_datetime DATETIME,
    end_datetime DATETIME,
    fee positiveFloat,
    engineer_id INT NOT NULL,
    booker_id INT NOT NULL,
    FOREIGN KEY (studio_id) REFERENCES Studios(studio_id),
    FOREIGN KEY (engineer_id) REFERENCES CertificatedEngineers(engineer_id),
    FOREIGN KEY (booker_id) REFERENCES Person(person_id),
    CONSTRAINT no_overlapping_sessions
        CHECK (NOT EXISTS (
            SELECT 1
            FROM Sessions s1, Sessions s2
            WHERE s1.session_id <> s2.session_id
              AND s1.studio_id = s2.studio_id
              AND s1.start_datetime = s2.start_datetime
        ))
);


-- This is where we should check if a session has <= 3 engineers.
--session_engineer_pax identifies the i-th engineer for a session. Note that it
is at most 2 (since the 1st engineer is in Sessions). Note the unique
constraint. It ensures that no two engineers are marked as the ith engineer.
CREATE TABLE ExtraEngineersPerSession (
    session_id BIGINT,
    engineer_id INT NOT NULL,
    session_engineer_pax smallint IDENTITY(1,1),
    FOREIGN KEY (engineer_id) REFERENCES CertificatedEngineers(engineer_id),
    FOREIGN KEY (session_id) REFERENCES Sessions(session_id),
    PRIMARY KEY (session_id, engineer_id),
    CONSTRAINT at_most_three CHECK (session_engineer_pax >= 1 and
    session_engineer_pax <= 2);
    UNIQUE (session_id, engineer_id, session_engineer_pax)
);


-- This relation is valid since the primary key is eng_id, certificate_id. No
redundancy there.
CREATE TABLE CertificatedEngineers (
    engineer_id INT,
    certificate_id INT NOT NULL,
    FOREIGN KEY (engineer_id) REFERENCES Person(person_id),
    PRIMARY KEY(engineer_id, certificate_id)
);

-- Holds any individuals that will play in a session. NOTE: This is in addition
to the individual already defined in Sessions table.
CREATE TABLE SessionPerson (
    session_id BIGINT,
    player_id INT,
    FOREIGN KEY (player_id) REFERENCES Person(person_id),
    FOREIGN KEY (session_id) REFERENCES Sessions(session_id),
    PRIMARY KEY(session_id, player_id)
);

-- Holds any bands that will play in a session.
CREATE TABLE SessionBands (
    session_id BIGINT,
    band_id INT,
    FOREIGN KEY (engineer_id) REFERENCES Person(person_id),
    FOREIGN KEY (session_id) REFERENCES Sessions(session_id),
    PRIMARY KEY(session_id, player_id)
);


CREATE TABLE Person (
    person_id INT IDENTITY(1, 1) PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    phone_number CHAR(12) CHECK (phone_number LIKE '___-___-____')
);

CREATE TABLE Band (
    band_id INT IDENTITY(1, 1),
    name VARCHAR(255),
    member_id NOT NULL INT,
    FOREIGN KEY (member_id) REFERENCES Person(person_id),
    PRIMARY KEY(band_id, member_id)
);

-- Holds any additonal managers for a studio. 
-- NOTE: The primary key ensures that an manager can be rehired to be a manager
again at a later time. We assume that for some studio A, the start_date of any
new managers is AFTER the start date of studio A's og_manager (that is defined
in Studio), which we do not need to define.
CREATE TABLE NewManagers (
    manager_id INT,
    studio_id BIGINT,
    employment_start_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (managerID) REFERENCES Person(person_id),
    FOREIGN KEY (studio_id) REFERENCES Studios(studio_id),
    PRIMARY KEY (studio_id, manager_id, employment_start_date),
);


-- These are the segments associated to each session. 
-- NOTE: session_id is NOT NULL to ensure a segment is associated to EXACTLY one session.
CREATE TABLE Segment (
    segment_id INT IDENTITY(1,1) PRIMARY KEY,
    session_id INT NOT NULL,
    length positiveInt,
    format VARCHAR(80),
    FOREIGN KEY (session_id) REFERENCES Sessions(session_id)
);


-- Creates a relationship between tracks and recording segments.
CREATE TABLE TrackSegmentRelation (
    track_id INT,
    segment_id INT, 
    FOREIGN KEY (track_id) REFERENCES Track(track_id),
    FOREIGN KEY (segment_id) REFERENCES Segment(segment_id),
    PRIMARY KEY(track_id, segment_id)
);


-- Holds information about a track.
-- NOTE: In this implementation, we will NOT uphold the constraint "a track MUST
appear in at least one album". This is to avoid awkward circular FK as per @748.
This also makes sense in real life since some tracks are released as a single,
with the option to add that single to an album later on.
CREATE TABLE Track (
    track_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(80)
);

-- Holds information about the album.
-- NOTE: We must specify two preexisting DISTINCT tracks that must be added to the album
we just created.
CREATE TABLE Album (
    album_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(80),
    release_date DATE,
    og_track1 INT,
    og_track2 INT,
    FOREIGN KEY (og_track1) REFERENCES Track(track_id),
    FOREIGN KEY (og_track2) REFERENCES Track(track_id),
    CONSTRAINT CheckDistinctTracks CHECK (og_track1 <> og_track2)
);


-- This holds any additional tracks we want to add to an album.
CREATE TABLE TrackAlbumRelation (
    album_id INT,
    track_id INT,
    PRIMARY KEY (album_id, track_id),
    FOREIGN KEY (album_id) REFERENCES Album(album_id),
    FOREIGN KEY (track_id) REFERENCES Track(track_id)
);



-- Domains

CREATE DOMAIN positiveFloat AS real
    DEFAULT NULL
    CHECK (VALUE > 0.0);

CREATE DOMAIN positiveInt AS smallint
    DEFAULT NULL
    CHECK (VALUE > 0);

-- A trigger that inserts the og_track1, og_track2 into the Album.
CREATE OR REPLACE FUNCTION add_tracks_to_album() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO TrackAlbum (album_id, track_id) 
  VALUES (NEW.album_id, NEW.og_track1), (NEW.album_id, NEW.og_track2);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER add_tracks_after_album_creation
AFTER INSERT ON Album 
FOR EACH ROW EXECUTE PROCEDURE add_tracks_to_album();


-- A trigger to ensure that if every album has at least two tracks associated
with it.
CREATE OR REPLACE FUNCTION check_album_tracks()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT COUNT(*) FROM TrackAlbum WHERE album_id = NEW.album_id) < 2 THEN
    RAISE EXCEPTION 'An Album Must Have At Least Two Tracks';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_track_count 
AFTER INSERT OR DELETE ON TrackAlbum 
FOR EACH ROW EXECUTE PROCEDURE check_album_tracks();