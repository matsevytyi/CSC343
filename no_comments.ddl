DROP TABLE IF EXISTS Person CASCADE;

CREATE TABLE Person (
    person_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    phone_number CHAR(12) CHECK (phone_number LIKE '___-___-____')
);

DROP TABLE IF EXISTS Band CASCADE;

CREATE TABLE Band (
    band_id BIGSERIAL PRIMARY KEY,
    frontman_id INT NOT NULL,
    FOREIGN KEY (frontman_id) REFERENCES Person(person_id),
    name VARCHAR(255)
);

DROP TABLE IF EXISTS BandMembership CASCADE;

CREATE TABLE BandMembership (
    band_id BIGINT NOT NULL,
    member_id INT NOT NULL,
    FOREIGN KEY (member_id) REFERENCES Person(person_id),
    FOREIGN KEY (band_id) REFERENCES Band(band_id),
    PRIMARY KEY(band_id, member_id)
);

DROP TABLE IF EXISTS Certificates CASCADE;

CREATE TABLE Certificates (
    certificate_id SERIAL PRIMARY KEY
);

DROP TABLE IF EXISTS Engineer CASCADE;

CREATE TABLE Engineer (
    engineer_id BIGSERIAL NOT NULL PRIMARY KEY,
    main_certificate INT NOT NULL,
    FOREIGN KEY (engineer_id) REFERENCES Person(person_id),
    FOREIGN KEY (main_certificate) REFERENCES Certificates(certificate_id)
);

DROP TABLE IF EXISTS EngineersCertification CASCADE;

CREATE TABLE EngineersCertification (
    engineer_id BIGINT NOT NULL,
    certificate_id INT NOT NULL,
    FOREIGN KEY (engineer_id) REFERENCES Engineer(engineer_id),
    FOREIGN KEY (certificate_id) REFERENCES Certificates(certificate_id),
    PRIMARY KEY(engineer_id, certificate_id)
);

DROP TABLE IF EXISTS Studios CASCADE;

CREATE TABLE Studios (
    studio_id BIGSERIAL PRIMARY KEY,
    studio_name VARCHAR(255),
    address VARCHAR(255),
    og_manager_id INT,
    FOREIGN KEY (og_manager_id) REFERENCES Person(person_id)
);

DROP TABLE IF EXISTS ManagersHistory CASCADE;

CREATE TABLE ManagersHistory (
    manager_id INT NOT NULL,
    studio_id BIGINT NOT NULL,
    employment_start_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (manager_id) REFERENCES Person(person_id),
    FOREIGN KEY (studio_id) REFERENCES Studios(studio_id),
    PRIMARY KEY (studio_id, manager_id, employment_start_date)
);

DROP TABLE IF EXISTS Sessions CASCADE;

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

CREATE TABLE ExtraEngineersPerSession (
    session_id BIGINT,
    engineer_id INT NOT NULL,
    session_engineer_pax SERIAL,
    FOREIGN KEY (engineer_id) REFERENCES Engineer(engineer_id),
    FOREIGN KEY (session_id) REFERENCES Sessions(session_id),
    PRIMARY KEY (session_id, engineer_id),
    CONSTRAINT at_most_three CHECK (session_engineer_pax >= 1 and
    session_engineer_pax <= 2),
    UNIQUE (session_id, engineer_id, session_engineer_pax)
);

DROP TABLE IF EXISTS SessionPerson CASCADE;

CREATE TABLE SessionPerson (
    session_id BIGINT,
    player_id INT,
    FOREIGN KEY (player_id) REFERENCES Person(person_id),
    FOREIGN KEY (session_id) REFERENCES Sessions(session_id),
    PRIMARY KEY(session_id, player_id)
);

DROP TABLE IF EXISTS SessionBands CASCADE;

CREATE TABLE SessionBands (
    session_id BIGINT,
    band_id INT,
    FOREIGN KEY (session_id) REFERENCES Sessions(session_id),
    FOREIGN KEY (band_id) REFERENCES Band(band_id),
    PRIMARY KEY(session_id, band_id)
);

DROP TABLE IF EXISTS Track CASCADE;

CREATE TABLE Track (
    track_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(80)
);

DROP TABLE IF EXISTS Segment CASCADE;

CREATE TABLE Segment (
    segment_id BIGSERIAL PRIMARY KEY,
    session_id INT NOT NULL,
    length positiveInt,
    format VARCHAR(80),
    FOREIGN KEY (session_id) REFERENCES Sessions(session_id)
);

DROP TABLE IF EXISTS TrackSegmentRelation CASCADE;

CREATE TABLE TrackSegmentRelation (
    track_id INT,
    segment_id INT, 
    FOREIGN KEY (track_id) REFERENCES Track(track_id),
    FOREIGN KEY (segment_id) REFERENCES Segment(segment_id),
    PRIMARY KEY(track_id, segment_id)
);

DROP TABLE IF EXISTS Album CASCADE;

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