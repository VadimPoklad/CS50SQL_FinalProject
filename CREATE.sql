CREATE TABLE songs(
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    time TIME(0) NOT NULL,
    plays INT NOT NULL, -- plays this number of songs playing
    song BLOB           -- generally it is better to keep the songs separate
);                      -- and here indicate a link to the songs, but I did so to simplify

CREATE TABLE albums(
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    year YEAR NOT NULL
);

-- links the songs and albums tables
CREATE TABLE album_songs(
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    album_id BIGINT,
    song_id BIGINT,
    FOREIGN KEY (album_id) REFERENCES albums(id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE
);

CREATE TABLE genres(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50)
);

-- links the genres and albums tables
CREATE TABLE album_genres(
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    genre_id INT,
    album_id BIGINT,
    FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE SET NULL,
    FOREIGN KEY (album_id) REFERENCES albums(id) ON DELETE CASCADE
);

CREATE TABLE artists(
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- links the artists and albums tables
CREATE TABLE artist_albums(
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    album_id BIGINT UNIQUE,
    artist_id BIGINT,
    FOREIGN KEY (album_id) REFERENCES albums(id) ON DELETE CASCADE,
    FOREIGN KEY (artist_id) REFERENCES artists(id) ON DELETE CASCADE
);

CREATE TABLE users(
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(64) NOT NULL, -- save hash(sha-256) password
    type ENUM ('free', 'premium', 'student') DEFAULT 'free' NOT NULL,
    payment_date DATE DEFAULT NULL, -- the date when the subscription money will be requested. Can be NULL if type = free
    payment_details VARCHAR(29) DEFAULT NULL -- data with which we collect payment IBAN
);

CREATE TABLE playlists(
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(40),
    type ENUM('private', 'public')
);

-- links the playlists and songs tables
CREATE TABLE playlist_song(
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    playlist_id BIGINT,
    song_id BIGINT,
    FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE
);

-- links the playlists and users tables
CREATE TABLE user_playlists(
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    playlist_id BIGINT,
    user_id BIGINT,
    FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- links the albums and users tables
CREATE TABLE album_likes(
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT,
    album_id BIGINT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (album_id) REFERENCES albums(id) ON DELETE CASCADE
);

-- links the songs and users tables
CREATE TABLE song_likes(
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT,
    song_id BIGINT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE
);
-- number of songs on the albums
CREATE VIEW number_of_songs AS
    SELECT albums.id, albums.name, COUNT(songs.name) AS number
    FROM album_songs
    LEFT JOIN albums on albums.id = album_songs.album_id
    LEFT JOIN songs on songs.id = album_songs.song_id
    GROUP BY albums.id;

-- album’s listening count
CREATE VIEW albums_listening_count AS
SELECT albums.id, albums.name, SUM(plays) AS total_plays
FROM album_songs
         LEFT JOIN albums on albums.id = album_songs.album_id
         LEFT JOIN songs on songs.id = album_songs.song_id
GROUP BY albums.id;


CREATE INDEX artists_index ON artists(name);
CREATE INDEX songs_index ON songs(name);
CREATE INDEX users_index ON users(username);

-- Makes the subscription type "free" if the user has not paid within 5 days after the pay day
CREATE PROCEDURE lose_premium()
BEGIN
    UPDATE users
    SET type = 'free', payment_date = NULL, payment_details = NULL
    WHERE payment_date < DATE_ADD(CURDATE(), INTERVAL -5 DAY);
END;

-- If the user paid, extends his subscription for a month
CREATE PROCEDURE renewal_premium(re_id BIGINT)
BEGIN
    UPDATE users
    SET payment_date = DATE_ADD(payment_date, INTERVAL 1 MONTH)
    WHERE id = re_id;
END;

-- If the user buys a subscription for the first time, creates it a payment date and writes the type of subscription
CREATE PROCEDURE buy_premium(re_id BIGINT, new_type ENUM ('premium', 'student'), IBAN VARCHAR(29))
BEGIN
    UPDATE users
    SET type = new_type, payment_date = DATE_ADD(CURDATE(), INTERVAL 1 MONTH), payment_details = IBAN
    WHERE id = re_id;
END;


-- If we delete album, we delete all songs from this album
CREATE TRIGGER delete_album_and_songs BEFORE DELETE ON albums
    FOR EACH ROW DELETE FROM songs WHERE id IN (
        SELECT song_id FROM album_songs WHERE album_id = OLD.id
    );

-- If we delete the artist, we delete all the artist’s albums
CREATE TRIGGER delete_artist_and_albums BEFORE DELETE ON artists
    FOR EACH ROW DELETE FROM albums WHERE id IN (
        SELECT album_id FROM artist_albums WHERE artist_id = OLD.id
    );

-- If we delete the user, we delete all the user’s playlists
CREATE TRIGGER delete_user_and_playlists BEFORE DELETE ON users
    FOR EACH ROW DELETE FROM playlists WHERE id IN (
    SELECT playlist_id FROM user_playlists WHERE user_id = OLD.id
);