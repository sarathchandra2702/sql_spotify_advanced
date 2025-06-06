# Spotify Advanced SQL Project and Query Optimization

## Overview
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **SQL**. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries, and optimizing query performance. The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset.

```sql
-- creating a table called spotify
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
```
## Project Steps

### Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:
- `Artist`: The performer of the track.
- `Track`: The name of the song.
- `Album`: The album to which the track belongs.
- `Album_type`: The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

### Querying the Data
After the data is inserted, various SQL queries can be written to explore and analyze the data. 

## EDA

## counting number of rows in the spotify table
```sql
SELECT COUNT(*) FROM spotify;
```

## counting number of unique artists in the dataset
```sql
SELECT COUNT(DISTINCT artist) FROM spotify;
```

## counting number of unique albums in the dataset
```sql
SELECT COUNT(DISTINCT album) FROM spotify;
```

## distinct album_types in the dataset
```sql
SELECT DISTINCT album_type FROM spotify;
```

## now looking at durations column
```sql
SELECT duration_min FROM spotify;
```

## max duration
```sql
SELECT MAX(duration_min) FROM spotify;
```

## min duration
```sql
SELECT MIN(duration_min) FROM spotify;
```

## Seeing which song is having duration_min = 0 and deleting that record because there will be no song with 0 min as duration.
```sql
SELECT * FROM spotify
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min = 0;
```

## seeing different types of channels that the dataset have
```sql
SELECT DISTINCT channel FROM spotify;
```

## seeing what are the most used websites for playing songs
```sql
SELECT DISTINCT most_played_on FROM spotify;
```

### Query Optimization
In advanced stages, the focus shifts to improving query performance. Some optimization strategies include:
- **Indexing**: Adding indexes on frequently queried columns.
- **Query Execution Plan**: Using `EXPLAIN ANALYZE` to review and refine query performance.
  

## 15 Practice Questions

## 1. Retrieve the names of all tracks that have more than 1 billion streams.
```sql
SELECT * FROM spotify;

SELECT track FROM spotify
WHERE stream>1000000000;
```

## 2. List all albums along with their respective artists.
```sql
SELECT * FROM spotify;

SELECT DISTINCT album,artist FROM spotify ORDER BY album;
```

## 3. Get the total number of comments for tracks where `licensed = TRUE`.
```sql
SELECT SUM(comments) FROM spotify
WHERE licensed = 'True';
```

## 4. Find all tracks that belong to the album type `single`.
```sql
SELECT track FROM spotify
WHERE album_type = 'single';
```

## 5. Count the total number of tracks by each artist.
```sql
SELECT artist,COUNT(track)
FROM spotify
GROUP BY artist;
```

## 6. Calculate the average danceability of tracks in each album.
```sql
SELECT * FROM spotify;

SELECT album,AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY album
ORDER BY avg_danceability DESC;
```

## 7. Find the top 5 tracks with the highest energy values.
```sql
SELECT * FROM spotify;

SELECT track FROM spotify
ORDER BY energy DESC LIMIT 5;
```

## 8. List all tracks along with their views and likes where `official_video = TRUE`.
```sql
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
```

## 9. For each album, calculate the total views of all associated tracks.
```sql
SELECT album,track,SUM(views) AS total_views
FROM spotify
GROUP BY album,track
ORDER BY total_views DESC;
```

## 10. Retrieve the track names that have been streamed on Spotify more than YouTube.
```sql
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
```

## 11. Find the top 3 most-viewed tracks for each artist using window functions.
```sql
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
```

## 12. Write a query to find tracks where the liveness score is above the average.
```sql
SELECT * FROM spotify;


SELECT track,liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);
```

## 13. **Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.**
```sql
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
```
   
## 14. Find tracks where the energy-to-liveness ratio is greater than 1.2.
```sql
SELECT track, (energy / liveness) AS energy_liveness_ratio
FROM spotify
WHERE (energy / liveness) > 1.2
ORDER BY energy_liveness_ratio ASC;
```

## 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
```sql
SELECT * FROM spotify;

SELECT 
	album,
	track,
	SUM(likes)
FROM spotify
GROUP BY album,track,views
ORDER BY views;
```


---

## Query Optimization Technique 

To improve query performance, we carried out the following optimization process:

- **Initial Query Performance Analysis Using `EXPLAIN`**
    - We began by analyzing the performance of a query using the `EXPLAIN` function.
    - The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
        - Execution time (E.T.): **0.171 ms**
        - Planning time (P.T.): **10.599 ms**
    - Below is the **screenshot** of the `EXPLAIN` result before optimization:
      ![EXPLAIN Before Index](https://github.com/sarathchandra2702/sql_spotify_advanced/blob/main/Explain_analyze_before_index.png)

- **Index Creation on the `artist` Column**
    - To optimize the query performance, we created an index on the `artist` column. This ensures faster retrieval of rows where the artist is queried.
    - **SQL command** for creating the index:
      ```sql
      CREATE INDEX artist_index ON spotify(artist);
      ```

- **Performance Analysis After Index Creation**
    - After creating the index, we ran the same query again and observed significant improvements in performance:
        - Execution time (E.T.): **0.292 ms**
        - Planning time (P.T.): **0.166 ms**
    - Below is the **screenshot** of the `EXPLAIN` result after index creation:
      ![EXPLAIN After Index](https://github.com/sarathchandra2702/sql_spotify_advanced/blob/main/Explain_analyze_after_index.png)

- **Graphical and Analysis Comparison**
    - **Graph view** :
      ![Graphical Explanation before index](https://github.com/sarathchandra2702/sql_spotify_advanced/blob/main/Graphical_Explanation_before_index.png)
      ![Graphical Explanation after index](https://github.com/sarathchandra2702/sql_spotify_advanced/blob/main/Graphical_Explanation_after_index.png)
    - **Analysis view**:
      ![Analysis before index](https://github.com/sarathchandra2702/sql_spotify_advanced/blob/main/Analysis_before_index.png)
      ![Analysis after index](https://github.com/sarathchandra2702/sql_spotify_advanced/blob/main/Analysis_after_index.png)

This optimization shows how indexing can drastically reduce query time, improving the overall performance of our database operations in the Spotify project.
---

## Technology Stack
- **Database**: PostgreSQL
- **SQL Queries**: DDL, DML, Aggregations, Joins, Subqueries, Window Functions
- **Tools**: pgAdmin 4 (or any SQL editor), PostgreSQL 

---



