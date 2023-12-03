-- Inserting data into Person table
INSERT INTO Person (person_id, name, email, phone_number) VALUES
  (1233, 'Donna Meagle', 'donna@example.com', '123-456-7890'),
  (1234, 'Tom Haverford', 'tom@example.com', '234-567-8901'),
  (1231, 'April Ludgate', 'april@example.com', '345-678-9012'),
  (1232, 'Leslie Knope', 'leslie@example.com', '456-789-0123'),
  (5678, 'Ben Wyatt', 'ben@example.com', '567-890-1234'),
  (9942, 'Ann Perkins', 'ann@example.com', '678-901-2345'),
  (6521, 'Chris Traeger', 'chris@example.com', '789-012-3456'),
  (6754, 'Andy Dwyer', 'andy@example.com', '890-123-4567'),
  (4523, 'Andrew Burlinson', 'andrew@example.com', '901-234-5678'),
  (2224, 'Michael Chang', 'michael@example.com', '012-345-6789'),
  (7832, 'James Pierson', 'james@example.com', '123-234-5678'),
  (1000, 'Duke Silver', 'duke@example.com', '234-345-6789');

-- Inserting data into Band table
INSERT INTO Band (frontman_id, name) VALUES
  (6754, 'Mouse Rat');

-- Inserting data into BandMembership table
INSERT INTO BandMembership (band_id, member_id) VALUES
  (1, 6754), (1, 4523), (1, 2224), (1, 7832);

-- Inserting data into Certificates table
INSERT INTO Certificates (certificate_id) VALUES
    ('ABCDEFGH-123I'), ('JKLMNOPQ-456R'), ('SOUND-123-AUDIO');

-- Inserting data into Engineer table
INSERT INTO Engineer (engineer_id, main_certificate) VALUES
  (5678, 'ABCDEFGH-123I'),
  (9942, 'SOUND-123-AUDIO'),
  (6521, NULL);

-- Inserting data into EngineersCertification table
INSERT INTO EngineersCertification (engineer_id, certificate_id) VALUES
  (5678, 'ABCDEFGH-123I'), (5678, 'JKLMNOPQ-456R'), (9942, 'ABCDEFGH-123I');

-- Inserting data into Studios table
INSERT INTO Studios (studio_id, studio_name, address, og_manager_id) VALUES
  (1, 'Pawnee Recording Studio', '123 Valley Spring Lane, Pawnee, Indiana', 1233),
  (2, 'Pawnee Sound', '353 Western Ave, Pawnee, Indiana', 1233),
  (3, 'Eagleton Recording Studio', '829 Division, Eagleton, Indiana', 1232);

-- Inserting data into ManagersHistory table
INSERT INTO ManagersHistory (manager_id, studio_id, employment_start_date) VALUES
  (1233, 1, '2018-12-02'),
  (1234, 1, '2017-01-13'),
  (1231, 1, '2008-03-21'),
  (1233, 2, '2011-05-07'),
  (1232, 3, '2020-09-05'),
  (1234, 3, '2016-09-05'),
  (1232, 3, '2010-09-05');

-- Inserting data into MySessions table
-- First set of sessions
INSERT INTO MySessions (studio_id, start_datetime, end_datetime, fee, engineer_id, booker_id)
VALUES
  (1, '2023-01-08 10:00', '2023-01-08 15:00', 1500, 5678, 6754),
  (1, '2023-01-10 13:00', '2023-01-11 14:00', 1500, 5678, 6754),
  (1, '2023-01-12 18:00', '2023-01-13 20:00', 1500, 5678, 6754);

INSERT INTO ExtraEngineersPerSession (session_id, engineer_id, session_engineer_pax)
VALUES
  (1, 9942, 1),
  (2, 9942, 1),
  (3, 9942, 1);

-- Second set of sessions
INSERT INTO MySessions (studio_id, start_datetime, end_datetime, fee, engineer_id, booker_id)
VALUES
  (1, '2023-03-10 11:00', '2023-03-10 23:00', 2000, 5678, 6754),
  (1, '2023-03-11 13:00', '2023-03-12 15:00', 2000, 5678, 6754);

-- Third set of sessions
INSERT INTO MySessions (studio_id, start_datetime, end_datetime, fee, engineer_id, booker_id)
VALUES
  (1, '2023-03-13 10:00', '2023-03-13 20:00', 1000, 6521, 6754);

-- Fourth set of sessions
INSERT INTO MySessions (studio_id, start_datetime, end_datetime, fee, engineer_id, booker_id)
VALUES
  (3, '2023-09-25 11:00', '2023-09-26 23:00', 1000, 5678, 6754),
  (3, '2023-09-29 11:00', '2023-09-30 23:00', 1000, 5678, 6754);

-- Inserting data into SessionPerson table
INSERT INTO SessionPerson (session_id, player_id) VALUES
  (1, 1000),
  (2, 1000),
  (3, 1000),
  (6, 6754),
  (6, 1234),
  (7, 6754),
  (8, 6754);

-- Inserting data into SessionBands table
INSERT INTO SessionBands (session_id, band_id) VALUES
  (1, 1),
  (2, 1),
  (3, 1),
  (4, 1), 
  (5, 1);

-- Inserting data into Track table
INSERT INTO Track (name) VALUES
  ('5,000 Candles in the Wind'),
  ('Catch Your Dream'),
  ('May Song'),
  ('The Pit'),
  ('Remember'),
  ('The Way You Look Tonight'),
  ('Another Song');

-- Inserting data into Segment table
INSERT INTO Segment (session_id, length, format) VALUES
  (1, 1, 'WAV'),
  (1, 1, 'WAV'),
  (1, 1, 'WAV'),
  (1, 1, 'WAV'),
  (1, 1, 'WAV'),
  (1, 1, 'WAV'),
  (1, 1, 'WAV'),
  (1, 1, 'WAV'),
  (1, 1, 'WAV'),
  (1, 1, 'WAV'),
  (2, 1, 'WAV'),
  (2, 1, 'WAV'),
  (2, 1, 'WAV'),
  (2, 1, 'WAV'),
  (2, 1, 'WAV'),
  (3, 1, 'WAV'),
  (3, 1, 'WAV'),
  (3, 1, 'WAV'),
  (3, 1, 'WAV'),
  (4, 2, 'WAV'),
  (4, 2, 'WAV'),
  (6, 1, 'WAV'),
  (6, 1, 'WAV'),
  (6, 1, 'WAV'),
  (6, 1, 'WAV'),
  (6, 1, 'WAV'),
  (7, 3, 'AIFF'),
  (7, 3, 'AIFF'),
  (7, 3, 'AIFF'),
  (7, 3, 'AIFF'),
  (7, 3, 'AIFF'),
  (7, 3, 'AIFF'),
  (7, 3, 'AIFF'),
  (7, 3, 'AIFF'),
  (7, 3, 'AIFF'),
  (8, 3, 'WAV'),
  (8, 3, 'WAV'),
  (8, 3, 'WAV'),
  (8, 3, 'WAV'),
  (8, 3, 'WAV'),
  (8, 8, 'WAV');

-- Inserting data into TrackSegmentRelation table
INSERT INTO TrackSegmentRelation (track_id, segment_id) 
VALUES
  (1, 11),
  (1, 12),
  (1, 13),
  (1, 14),
  (1, 15),
  (2, 16),
  (2, 17),
  (2, 18),
  (2, 19),
  (2, 20),
  (2, 21),
  (1, 22),
  (2, 22), 
  (1, 23),
  (2, 23),
  (1, 24),
  (2, 24),
  (1, 25),
  (2, 25),
  (1, 26), 
  (2, 26),
  (3, 32),
  (3, 33),
  (4, 34),
  (4, 35),
  (5, 36),
  (5, 37),
  (6, 38),
  (6, 39),
  (7, 40),
  (7, 41);

-- Inserting data into Album table
INSERT INTO Album (name, release_date, first_og_track, second_og_track) VALUES
  ('The Awesome Album', '2023-05-25', 1, 2),
  ('Another Awesome Album', '2023-10-29', 4, 5);

-- Inserting data into TrackAlbumRelation table
INSERT INTO TrackAlbumRelation (album_id, track_id) VALUES
  (1, 1),
  (1, 2),
  (2, 3),
  (2, 4),
  (2, 5),
  (2, 6),
  (2, 7);