-- SQL Project on spotify dataset

-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

--EDA

--counting number of rows in the spotify table
SELECT COUNT(*) FROM spotify;

--counting number of unique artists in the dataset
SELECT COUNT(DISTINCT artist) FROM spotify;

--counting number of unique albums in the dataset
SELECT COUNT(DISTINCT album) FROM spotify;

--distinct album_types in the dataset
SELECT DISTINCT album_type FROM spotify;

--now looking at durations column
SELECT duration_min FROM spotify;

--max duration
SELECT MAX(duration_min) FROM spotify;

--min duration
SELECT MIN(duration_min) FROM spotify;

--Seeing which song is having duration_min = 0 and deleting that record because there will be no song with 0 min as duration.
SELECT * FROM spotify
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min = 0;

--seeing different types of channels that the dataset have
SELECT DISTINCT channel FROM spotify;

--seeing what are the most used websites for playing songs
SELECT DISTINCT most_played_on FROM spotify;


---- DATA ANALYSIS

-- 1.Retrieve the names of all tracks that have more than 1 billion streams.
SELECT * FROM spotify;

SELECT track FROM spotify
WHERE stream>1000000000;

-- 2.List all albums along with their respective artists.
SELECT * FROM spotify;

SELECT DISTINCT album,artist FROM spotify ORDER BY album;

-- 3.Get the total number of comments for tracks where `licensed = TRUE`.
SELECT SUM(comments) FROM spotify
WHERE licensed = 'True';

-- 4.Find all tracks that belong to the album type `single`.
SELECT track FROM spotify
WHERE album_type = 'single';

-- 5.Count the total number of tracks by each artist.
SELECT artist,COUNT(track)
FROM spotify
GROUP BY artist;

--------------------------------

--6.Calculate the average danceability of tracks in each album.
SELECT * FROM spotify;

SELECT album,AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY album
ORDER BY avg_danceability DESC;

--7.Find the top 5 tracks with the highest energy values.
SELECT * FROM spotify;

SELECT track FROM spotify
ORDER BY energy DESC LIMIT 5;

--8. List all tracks along with their views and likes where `official_video = TRUE`.
SELECT * FROM spotify;

SELECT 
	track,
	SUM(views) AS total_views,
	SUM(likes) AS total_likes 
FROM spotify
WHERE official_video = 'true'
GROUP BY track
ORDER BY SUM(likes) DESC
LIMIT 5;

--9.For each album, calculate the total views of all associated tracks.
SELECT album,track,SUM(views) AS total_views
FROM spotify
GROUP BY album,track
ORDER BY total_views DESC;

--10.Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM spotify;

SELECT * FROM
(SELECT
	track,
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) AS streamed_on_youtube,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) AS streamed_on_spotify
FROM spotify
GROUP BY track) AS t1
WHERE 
	streamed_on_spotify > streamed_on_youtube
	AND
	streamed_on_youtube > 0;

--11.Find the top 3 most-viewed tracks for each artist using window functions.
SELECT * FROM spotify;

-- each artists and total view for each track
-- track with highest view for each artist ( we need top)
-- dense rank
-- cte and filter rank <=3

WITH ranking_artist
AS
(SELECT
	artist,
	track,
	SUM(views) AS total_view,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rank
FROM spotify
GROUP BY artist,track
ORDER BY artist,SUM(views) DESC
)
SELECT * FROM ranking_artist
WHERE rank<=3;

--12.Write a query to find tracks where the liveness score is above the average.
SELECT * FROM spotify;


SELECT track,liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);

--13.Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.
SELECT * FROM spotify;

WITH energy_difference
AS
(
	SELECT 
		album,
		MAX(energy) AS highest_energy,
		MIN(energy) AS lowest_energy
	FROM spotify
	GROUP BY album
)
SELECT 
	album,
	highest_energy - lowest_energy as energy_diff
FROM energy_difference
ORDER BY energy_diff DESC;

--14.Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT track, (energy / liveness) AS energy_liveness_ratio
FROM spotify
WHERE (energy / liveness) > 1.2
ORDER BY energy_liveness_ratio ASC;

--15.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT * FROM spotify;

SELECT 
	album,
	track,
	SUM(likes)
FROM spotify
GROUP BY album,track,views
ORDER BY views;


-- Query Optimization

EXPLAIN ANALYZE --et: 18.74 ms, pt: 0.102 ms
SELECT 
	artist,
	track,
	views
FROM spotify
WHERE artist = 'Gorillaz'
	AND 
	most_played_on = 'Youtube'
ORDER BY stream DESC LIMIT 25;

CREATE INDEX artist_index ON spotify(artist);
