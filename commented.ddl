-- COULD NOT: The domain required that a track must belong in at least one 
-- album. Italso required that an album must have at least two tracks.
-- This specifications imply a circular dependency, that require triggers.
-- We decided to NOT do the former, but still do the latter. This way, the
-- circular dependency is avoided. It also makes sense as a database designer 
-- since some tracks can be released independent (i.e. as a single) from an 
-- album. Moreover, it does not make sense for an album to get released 
-- with no tracks in it. 

-- DID NOT: None.

-- EXTRA CONSTRAINTS: None.

-- ASSUMPTIONS:
-- Here are a list of assumptions in the database design:
--      a. Once a new studio is created, there must also 
--          be a manager for that studio at the same time.
--      b. EXACTLY one person books a session.
--      c. The person who booked the session must play in that session.
--      d. If a band wants to book a session, one representative member
--          of the band must book that session.
DROP TABLE IF EXISTS Person CASCADE;

-- A person named <name> is identified by a unique <person_id>. The table also 
-- holds other information like email and phone number.
CREATE TABLE Person (
    person_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    phone_number CHAR(12) CHECK (phone_number LIKE '___-___-____')
);

DROP TABLE IF EXISTS Band CASCADE;

-- A band is uniquely identified by <band_id>, and was started by
-- <frontman_id> who is ASSUMED to be a band member. Typically they are 
-- the lead vocalists.
CREATE TABLE Band (
    band_id BIGSERIAL PRIMARY KEY,
    frontman_id INT NOT NULL,
    FOREIGN KEY (frontman_id) REFERENCES Person(person_id),
    name VARCHAR(255)
);

DROP TABLE IF EXISTS BandMembership CASCADE;

-- <member_id> is part of the band <band_id>. Note that this table 
-- does not include the original founder of the band.
CREATE TABLE BandMembership (
    band_id BIGINT NOT NULL,
    member_id INT NOT NULL,
    FOREIGN KEY (member_id) REFERENCES Person(person_id),
    FOREIGN KEY (band_id) REFERENCES Band(band_id),
    PRIMARY KEY(band_id, member_id)
);

DROP TABLE IF EXISTS Certificates CASCADE;

-- A valid certificate is uniquely identified by some <certificate_id>.
CREATE TABLE Certificates (
    certificate_id SERIAL PRIMARY KEY
);

DROP TABLE IF EXISTS Engineer CASCADE;

-- The engineers in the database. An engineer must have at least one 
-- certificate, identified by <main_certificate>. Typically, this is 
-- their Engineering Certification.
CREATE TABLE Engineer (
    engineer_id BIGSERIAL NOT NULL PRIMARY KEY,
    main_certificate INT NOT NULL,
    FOREIGN KEY (engineer_id) REFERENCES Person(person_id),
    FOREIGN KEY (main_certificate) REFERENCES Certificates(certificate_id)
);

DROP TABLE IF EXISTS EngineersCertification CASCADE;

-- Engineer <engineer_id> has any additional certificates <certificate_id>.
CREATE TABLE EngineersCertification (
    engineer_id BIGINT NOT NULL,
    certificate_id INT NOT NULL,
    FOREIGN KEY (engineer_id) REFERENCES Engineer(engineer_id),
    FOREIGN KEY (certificate_id) REFERENCES Certificates(certificate_id),
    PRIMARY KEY(engineer_id, certificate_id)
);

DROP TABLE IF EXISTS Studios CASCADE;

-- All the studios the company owns. It contains necessary info like
--<studio_id>, <studio_name> and <address>. A new studio MUST have exactly one
-- original manager, with an ID of <og_manager_id>.
CREATE TABLE Studios (
    studio_id BIGSERIAL PRIMARY KEY,
    studio_name VARCHAR(255),
    address VARCHAR(255),
    og_manager_id INT NOT NULL,
    FOREIGN KEY (og_manager_id) REFERENCES Person(person_id)
);

DROP TABLE IF EXISTS ManagersHistory CASCADE;

-- all OTHER managers with some <manager_id>, managing some studio <studio_id>,
-- who started working on <employment_start_date>.
--
-- Note that the original manager for a studio is not in this relation.
CREATE TABLE ManagersHistory (
    manager_id INT NOT NULL,
    studio_id BIGINT NOT NULL,
    employment_start_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (manager_id) REFERENCES Person(person_id),
    FOREIGN KEY (studio_id) REFERENCES Studios(studio_id),
    PRIMARY KEY (studio_id, manager_id, employment_start_date)
);

DROP TABLE IF EXISTS Sessions CASCADE;

-- A recording session uniquely identified with <session_id> that 
-- occured at some studio with ID <studio_id>. 
--
-- It also holds start and end timestamps and fee for the session.
--
-- A person with ID <booker_id> booked the session, who is ASSUMED to
-- be be playing in that session. If a band books a session, a band member 
-- is ASSUMED to have booked that session. 
--
-- A session MUST also have an engineer with ID of <engineer_id>.
CREATE TABLE Sessions (
    session_id BIGSERIAL PRIMARY KEY,
    studio_id BIGINT,
    start_datetime TIMESTAMP,
    end_datetime TIMESTAMP,
    fee positiveFloat,
    engineer_id INT NOT NULL,
    booker_id INT NOT NULL,
    FOREIGN KEY (studio_id) REFERENCES Studios(studio_id),
    FOREIGN KEY (engineer_id) REFERENCES Engineer(engineer_id),
    FOREIGN KEY (booker_id) REFERENCES Person(person_id),
    UNIQUE (session_id, start_datetime)
);

DROP TABLE IF EXISTS ExtraEngineersPerSession CASCADE;

-- The extra engineers for some session. It holds the session's ID <session_id> 
-- and the <session_engineer_pos>-th engineer's ID with <engineer_id>.
--
-- Note that <session_engineer_pos> is either 2 or 3 to represent 
-- the 2nd and/or 3rd engineer, if necessary. The 1st engineer for a 
-- session <session_id> was defined when the session was created.
CREATE TABLE ExtraEngineersPerSession (
    session_id BIGINT,
    engineer_id INT NOT NULL,
    session_engineer_pos SERIAL,
    FOREIGN KEY (engineer_id) REFERENCES Engineer(engineer_id),
    FOREIGN KEY (session_id) REFERENCES Sessions(session_id),
    PRIMARY KEY (session_id, engineer_id),
    CONSTRAINT at_most_three CHECK (session_engineer_pos >= 2 and
    session_engineer_pos <= 3),
    UNIQUE (session_id, engineer_id, session_engineer_pos)
);

DROP TABLE IF EXISTS SessionPerson CASCADE;

-- The individual persons with ID <player_id> playing in the session 
-- <session_id>.
CREATE TABLE SessionPerson (
    session_id BIGINT,
    player_id INT,
    FOREIGN KEY (player_id) REFERENCES Person(person_id),
    FOREIGN KEY (session_id) REFERENCES Sessions(session_id),
    PRIMARY KEY(session_id, player_id)
);

DROP TABLE IF EXISTS SessionBands CASCADE;

-- The bands playing with id <band_id> playing in the session 
-- <session_id>
CREATE TABLE SessionBands (
    session_id BIGINT,
    band_id INT,
    FOREIGN KEY (session_id) REFERENCES Sessions(session_id),
    FOREIGN KEY (band_id) REFERENCES Band(band_id),
    PRIMARY KEY(session_id, band_id)
);

DROP TABLE IF EXISTS Track CASCADE;

-- Track table holds all the music tracks. A track is named <name> which are 
-- uniquely identified by <track_id>. When a track is initally released, it 
-- is considered a single release so the track need not to belong in some 
-- album.
CREATE TABLE Track (
    track_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(80)
);

DROP TABLE IF EXISTS Segment CASCADE;

-- A segment of sound recording with ID <segment_id> from the session 
-- <session_id> that is <length> seconds long with a <format> type format.
CREATE TABLE Segment (
    segment_id BIGSERIAL PRIMARY KEY,
    session_id INT NOT NULL,
    length positiveInt,
    format VARCHAR(80),
    FOREIGN KEY (session_id) REFERENCES Sessions(session_id)
);

DROP TABLE IF EXISTS TrackSegmentRelation CASCADE;

-- A track <track_id> is composed of zero, one or multiple segments
-- of recording identified by <segment_id>.  
CREATE TABLE TrackSegmentRelation (
    track_id INT,
    segment_id INT, 
    FOREIGN KEY (track_id) REFERENCES Track(track_id),
    FOREIGN KEY (segment_id) REFERENCES Segment(segment_id),
    PRIMARY KEY(track_id, segment_id)
);

DROP TABLE IF EXISTS Album CASCADE;

-- The album <album_id> is originally composed of two tracks: <first_og_track>, 
-- <second_og_track>. The album is named <name> and will release on 
-- <release_date>.
CREATE TABLE Album (
    album_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(80),
    release_date DATE,
    first_og_track INT NOT NULL,
    second_og_track INT NOT NULL,
    FOREIGN KEY (first_og_track) REFERENCES Track(track_id),
    FOREIGN KEY (second_og_track) REFERENCES Track(track_id),
    CONSTRAINT CheckDistinctTracks CHECK (first_og_track <> second_og_track)
);

DROP TABLE IF EXISTS TrackAlbumRelation CASCADE;

-- Any additional tracks identified <track_id> that belongs to some 
-- album <album_id>.
CREATE TABLE TrackAlbumRelation (
    album_id INT NOT NULL,
    track_id INT NOT NULL,
    PRIMARY KEY (album_id, track_id),
    FOREIGN KEY (album_id) REFERENCES Album(album_id),
    FOREIGN KEY (track_id) REFERENCES Track(track_id)
);


-- Domains

DROP DOMAIN IF EXISTS positiveFloat CASCADE;

CREATE DOMAIN positiveFloat AS real
    DEFAULT NULL
    CHECK (VALUE > 0.0);

DROP DOMAIN IF EXISTS positiveInt CASCADE;

CREATE DOMAIN positiveInt AS smallint
    DEFAULT NULL
    CHECK (VALUE > 0);