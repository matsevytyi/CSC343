-- TODO: For the Studios relation, when we add a new Manager for the same
studio, Studios relation should get updated to point to the current manager (so
what we have is the current manager on studios instead of the original).
CREATE TABLE Studios (
    studio_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    studio_name VARCHAR(255),
    address VARCHAR(255),
    og_manager_id INT,
    FOREIGN KEY (og_manager_id) REFERENCES Manages(manager_id) 
);

CREATE TABLE Manages (
    manager_id INT,
    studio_id BIGINT,
    employment_start_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (managerID) REFERENCES Person(person_id),
    FOREIGN KEY (studio_id) REFERENCES Studios(studio_id),
    PRIMARY KEY (studio_id, manager_id, employment_start_date),
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


CREATE TABLE Sessions (
    session_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    studio_id BIGINT,
    start_datetime DATETIME,
    end_datetime DATETIME,
    fee positiveFloat,
    engineer_id INT NOT NULL, 
    player_id INT NOT NULL,
    player_type NOT NULL ENUM('individual', 'band'),
    FOREIGN KEY (studio_id) REFERENCES Studios(studio_id),
    FOREIGN KEY (engineer_id) REFERENCES Person(person_id),
    FOREIGN KEY (player_id) REFERENCES Players(player_id),
    CONSTRAINT no_overlapping_sessions
        CHECK (NOT EXISTS (
            SELECT 1
            FROM Sessions s1, Sessions s2
            WHERE s1.session_id <> s2.session_id
              AND s1.studio_id = s2.studio_id
              AND s1.start_datetime = s2.start_datetime
        ))
);

-- TODO: Hava a different table for the relationship between the engineers and
the session.
CREATE TABLE Engineers (
    engineer_id INT,
    session_id BIGINT, 
    certificate_id INT NOT NULL,
    FOREIGN KEY (session_id) REFERENCES Sessions(session_id),
    FOREIGN KEY (engineer_id) REFERENCES Person(person_id),
    PRIMARY KEY(engineer_id, session_id)
);

-- TODO: Have a different table for the relationship between the engineers and
the certificates.
CREATE TABLE Certificates (
    certificate_id INT IDENTITY(1,1) PRIMARY KEY,
    engineer_id INT,
    FOREIGN KEY (engineer_id) REFERENCES Engineers(engineer_id)
);

CREATE TABLE SessionPlayers (
    session_id INT,
    player_id INT,
    player_type ENUM('individual', 'band'),
    PRIMARY KEY (session_id, player_id, player_type),
    FOREIGN KEY (session_id) REFERENCES Sessions(session_id),
    FOREIGN KEY (player_id) REFERENCES Players(player_id) -- TODO: MISTAKE IT
    SHOULD BE BAND_ID OR PLAYER_ID. 
);

CREATE TABLE Segment (
    segment_id INT IDENTITY(1,1) PRIMARY KEY,
    session_id INT,
    length positiveInt,
    format VARCHAR(80),
    FOREIGN KEY (session_id) REFERENCES Sessions(session_id)
);

CREATE TABLE Track (
    track_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(80)
);

CREATE TABLE TrackSegment (
    track_id INT,
    segment_id INT, 
    FOREIGN KEY (track_id) REFERENCES Track(track_id),
    FOREIGN KEY (segment_id) REFERENCES Segment(segment_id),
    PRIMARY KEY(track_id, segment_id)
);

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

CREATE TABLE TrackAlbum (
    album_id INT,
    track_id INT,
    PRIMARY KEY (album_id, track_id),
    FOREIGN KEY (album_id) REFERENCES Album(album_id),
    FOREIGN KEY (track_id) REFERENCES Track(track_id)
);



-- Domains, triggers and extra material

CREATE DOMAIN positiveFloat AS real
    DEFAULT NULL
    CHECK (VALUE > 0.0);

CREATE DOMAIN positiveInt AS smallint
    DEFAULT NULL
    CHECK (VALUE > 0);

-- Checks if each session_id is associated with at most three engineer.
CREATE OR REPLACE FUNCTION check_engineer_limit()
    RETURNS TRIGGER AS
    $$
    DECLARE
        engineer_count INT;
    BEGIN
        SELECT COUNT(*) INTO engineer_count
        FROM Engineers
        WHERE session_id = NEW.session_id;

        IF engineer_count >= 3 THEN
            RAISE EXCEPTION 'Cannot assign more than three engineers to a single session';
        END IF;

        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER check_engineer_limit_trigger
    BEFORE INSERT ON Engineers
    FOR EACH ROW
    EXECUTE FUNCTION check_engineer_limit();

-- Every time data is inserted into sessions, it is also inserted into engineers.
CREATE OR REPLACE FUNCTION insert_into_engineers()
    RETURNS TRIGGER AS
    $$
    BEGIN
        INSERT INTO Engineers (engineer_id, session_id)
        VALUES (NEW.engineer_id, NEW.session_id);
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER insert_into_engineers_trigger
    AFTER INSERT ON Sessions
    FOR EACH ROW
    EXECUTE FUNCTION insert_into_engineers();


-- Everytime data is inserted into sessions, it is also inserted to SessionPlayers.
CREATE OR REPLACE FUNCTION insert_into_session_players()
    RETURNS TRIGGER AS
    $$
    BEGIN
        INSERT INTO SessionPlayers (session_id, player_id, player_type)
        VALUES (NEW.session_id, NEW.player_id, NEW.player_type);

        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER insert_into_session_players_trigger
    AFTER INSERT ON Sessions
    FOR EACH ROW
    EXECUTE FUNCTION insert_into_session_players();


-- This trigger ensures that adding a manager to a studio is reflected on the
manages table.
CREATE OR REPLACE FUNCTION add_to_manages() 
    RETURNS TRIGGER AS $$
    BEGIN
    INSERT INTO Manages (studio_id, manager_id, employment_start_date)
    VALUES (NEW.studio_id, NEW.first_manager_id, CURRENT_DATE);

    RETURN NEW;
    END;
    $$ LANGUAGE 'plpgsql';

CREATE TRIGGER insert_into_manages
    AFTER INSERT ON Studio
    FOR EACH ROW 
    EXECUTE FUNCTION add_to_manages();

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