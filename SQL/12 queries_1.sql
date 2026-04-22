12 queries 
-- PROJECT: Top Soccer Teams Progression from 2008 to 2016


-- QUERY 1 (JOIN)
-- What are the top 10 teams with the most wins from 2008 to 2016?

SELECT TOP 10
    t.team_long_name AS team_name,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS total_wins
FROM Match m
JOIN Team t ON m.home_team_api_id = t.team_api_id
GROUP BY t.team_long_name
ORDER BY total_wins DESC;



-- QUERY 2 (JOIN)
-- What leagues do our top teams play in?

SELECT
    t.team_long_name AS team_name,
    l.name AS league_name
FROM Team t
JOIN Match m ON t.team_api_id = m.home_team_api_id
JOIN League l ON m.league_id = l.id
GROUP BY t.team_long_name, l.name
ORDER BY t.team_long_name;



-- QUERY 3 (JOIN)
-- How many goals did each team score at home across all seasons?

SELECT TOP 15
    t.team_long_name AS team_name,
    SUM(m.home_team_goal) AS total_goals_scored
FROM Match m
JOIN Team t ON m.home_team_api_id = t.team_api_id
GROUP BY t.team_long_name
ORDER BY total_goals_scored DESC;



-- QUERY 4 (JOIN)
-- How many wins did the top 5 teams get each season?

SELECT
    t.team_long_name AS team_name,
    m.season,
    SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS wins
FROM Match m
JOIN Team t ON m.home_team_api_id = t.team_api_id
WHERE t.team_long_name IN (
    'FC Barcelona',
    'Real Madrid CF',
    'Juventus',
    'FC Bayern Munich',
    'Chelsea'
)
GROUP BY t.team_long_name, m.season
ORDER BY t.team_long_name, m.season;



-- QUERY 5 (JOIN)
-- What is the win percentage for each team across all seasons?
SELECT TOP 20
    t.team_long_name AS team_name,
    COUNT(*) AS total_matches,
    SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS wins,
    ROUND(
        CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
        / COUNT(*) * 100, 2
    ) AS win_percentage
FROM Match m
JOIN Team t ON m.home_team_api_id = t.team_api_id
GROUP BY t.team_long_name
ORDER BY win_percentage DESC;


-- QUERY 6 (JOIN)
-- How many wins, draws and losses did our top 5 teams have total?
SELECT
    t.team_long_name AS team_name,
    SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN m.home_team_goal = m.away_team_goal THEN 1 ELSE 0 END) AS draws,
    SUM(CASE WHEN m.home_team_goal < m.away_team_goal THEN 1 ELSE 0 END) AS losses
FROM Match m
JOIN Team t ON m.home_team_api_id = t.team_api_id
WHERE t.team_long_name IN (
    'FC Barcelona',
    'Real Madrid CF',
    'Juventus',
    'FC Bayern Munich',
    'Chelsea'
)
GROUP BY t.team_long_name
ORDER BY wins DESC;


-- QUERY 7 (JOIN + GROUP BY + HAVING)
-- Which teams won more than 100 games total at home?
SELECT
    t.team_long_name AS team_name,
    SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS total_wins
FROM Match m
JOIN Team t ON m.home_team_api_id = t.team_api_id
GROUP BY t.team_long_name
HAVING SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) > 100
ORDER BY total_wins DESC;

 
-- QUERY 8 (VARIABLES)
-- Which teams had the most wins in a specific season?

DECLARE @Season VARCHAR(10) = '2015/2016';

SELECT TOP 10
    t.team_long_name AS team_name,
    m.season,
    SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS wins
FROM Match m
JOIN Team t ON m.home_team_api_id = t.team_api_id
WHERE m.season = @Season
GROUP BY t.team_long_name, m.season
ORDER BY wins DESC;


-- QUERY 9 (SUBQUERY)
-- Which teams have a higher win total than the average teaams
SELECT
    t.team_long_name AS team_name,
    SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS total_wins
FROM Match m
JOIN Team t ON m.home_team_api_id = t.team_api_id
GROUP BY t.team_long_name
HAVING SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) >
    (
        -- Subquery: get the average wins per team
        SELECT AVG(team_wins) FROM (
            SELECT SUM(CASE WHEN home_team_goal > away_team_goal THEN 1 ELSE 0 END) AS team_wins
            FROM Match
            GROUP BY home_team_api_id
        ) AS avg_table
    )
ORDER BY total_wins DESC;


-- QUERY 10 (CTE)
-- What is the season by season win rate for our top 5 teams?
WITH SeasonWins AS (
    SELECT
        t.team_long_name AS team_name,
        m.season,
        COUNT(seasonwins.team_name, seasonwins.season, seasonwins.total_matches, seasonwins.wins, m.id, m.country_id, m.league_id, m.season, m.stage, m.date, m.match_api_id, m.home_team_api_id, m.away_team_api_id, m.home_team_goal, m.away_team_goal, m.home_player_X1, m.home_player_X2, m.home_player_X3, m.home_player_X4, m.home_player_X5, m.home_player_X6, m.home_player_X7, m.home_player_X8, m.home_player_X9, m.home_player_X10, m.home_player_X11, m.away_player_X1, m.away_player_X2, m.away_player_X3, m.away_player_X4, m.away_player_X5, m.away_player_X6, m.away_player_X7, m.away_player_X8, m.away_player_X9, m.away_player_X10, m.away_player_X11, m.home_player_Y1, m.home_player_Y2, m.home_player_Y3, m.home_player_Y4, m.home_player_Y5, m.home_player_Y6, m.home_player_Y7, m.home_player_Y8, m.home_player_Y9, m.home_player_Y10, m.home_player_Y11, m.away_player_Y1, m.away_player_Y2, m.away_player_Y3, m.away_player_Y4, m.away_player_Y5, m.away_player_Y6, m.away_player_Y7, m.away_player_Y8, m.away_player_Y9, m.away_player_Y10, m.away_player_Y11, m.home_player_1, m.home_player_2, m.home_player_3, m.home_player_4, m.home_player_5, m.home_player_6, m.home_player_7, m.home_player_8, m.home_player_9, m.home_player_10, m.home_player_11, m.away_player_1, m.away_player_2, m.away_player_3, m.away_player_4, m.away_player_5, m.away_player_6, m.away_player_7, m.away_player_8, m.away_player_9, m.away_player_10, m.away_player_11, m.goal, m.shoton, m.shotoff, m.foulcommit, m.card, m.cross, m.corner, m.possession, m.B365H, m.B365D, m.B365A, m.BWH, m.BWD, m.BWA, m.IWH, m.IWD, m.IWA, m.LBH, m.LBD, m.LBA, m.PSH, m.PSD, m.PSA, m.WHH, m.WHD, m.WHA, m.SJH, m.SJD, m.SJA, m.VCH, m.VCD, m.VCA, m.GBH, m.GBD, m.GBA, m.BSH, m.BSD, m.BSA, t.id, t.team_api_id, t.team_fifa_api_id, t.team_long_name, t.team_short_name, avg_table.team_wins, l.id, l.country_id, l.name, c.id, c.name, vw_teamseasonperformance.team_name, vw_teamseasonperformance.team_abbr, vw_teamseasonperformance.league, vw_teamseasonperformance.country, vw_teamseasonperformance.season, vw_teamseasonperformance.total_matches, vw_teamseasonperformance.wins, vw_teamseasonperformance.draws, vw_teamseasonperformance.losses, vw_teamseasonperformance.goals_scored, vw_teamseasonperformance.goals_conceded, vw_teamseasonperformance.goal_difference, vw_teamseasonperformance.win_percentage) AS total_matches,
        SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS wins
    FROM Match m
    JOIN Team t ON m.home_team_api_id = t.team_api_id
    WHERE t.team_long_name IN (
        'FC Barcelona',
        'Real Madrid CF',
        'Juventus',
        'FC Bayern Munich',
        'Chelsea'
    )
    GROUP BY t.team_long_name, m.season
)
SELECT
    team_name,
    season,
    wins,
    total_matches,
    ROUND(CAST(wins AS FLOAT) / total_matches m.id, m.country_id, m.league_id, m.season, m.stage, m.date, m.match_api_id, m.home_team_api_id, m.away_team_api_id, m.home_team_goal, m.away_team_goal, m.home_player_X1, m.home_player_X2, m.home_player_X3, m.home_player_X4, m.home_player_X5, m.home_player_X6, m.home_player_X7, m.home_player_X8, m.home_player_X9, m.home_player_X10, m.home_player_X11, m.away_player_X1, m.away_player_X2, m.away_player_X3, m.away_player_X4, m.away_player_X5, m.away_player_X6, m.away_player_X7, m.away_player_X8, m.away_player_X9, m.away_player_X10, m.away_player_X11, m.home_player_Y1, m.home_player_Y2, m.home_player_Y3, m.home_player_Y4, m.home_player_Y5, m.home_player_Y6, m.home_player_Y7, m.home_player_Y8, m.home_player_Y9, m.home_player_Y10, m.home_player_Y11, m.away_player_Y1, m.away_player_Y2, m.away_player_Y3, m.away_player_Y4, m.away_player_Y5, m.away_player_Y6, m.away_player_Y7, m.away_player_Y8, m.away_player_Y9, m.away_player_Y10, m.away_player_Y11, m.home_player_1, m.home_player_2, m.home_player_3, m.home_player_4, m.home_player_5, m.home_player_6, m.home_player_7, m.home_player_8, m.home_player_9, m.home_player_10, m.home_player_11, m.away_player_1, m.away_player_2, m.away_player_3, m.away_player_4, m.away_player_5, m.away_player_6, m.away_player_7, m.away_player_8, m.away_player_9, m.away_player_10, m.away_player_11, m.goal, m.shoton, m.shotoff, m.foulcommit, m.card, m.cross, m.corner, m.possession, m.B365H, m.B365D, m.B365A, m.BWH, m.BWD, m.BWA, m.IWH, m.IWD, m.IWA, m.LBH, m.LBD, m.LBA, m.PSH, m.PSD, m.PSA, m.WHH, m.WHD, m.WHA, m.SJH, m.SJD, m.SJA, m.VCH, m.VCD, m.VCA, m.GBH, m.GBD, m.GBA, m.BSH, m.BSD, m.BSA, t.id, t.team_api_id, t.team_fifa_api_id, t.team_long_name, t.team_short_name, avg_table.team_wins, l.id, l.country_id, l.name, c.id, c.name, vw_teamseasonperformance.team_name, vw_teamseasonperformance.team_abbr, vw_teamseasonperformance.league, vw_teamseasonperformance.country, vw_teamseasonperformance.season, vw_teamseasonperformance.total_matches, vw_teamseasonperformance.wins, vw_teamseasonperformance.draws, vw_teamseasonperformance.losses, vw_teamseasonperformance.goals_scored, vw_teamseasonperformance.goals_conceded, vw_teamseasonperformance.goal_difference, vw_teamseasonperformance.win_percentage 100, 2) AS win_pct
FROM SeasonWins
ORDER BY team_name, season;



-- QUERY 11 -- GOAL 4: Which leagues produced the most dominant teams?
SELECT
    l.name                                                                  AS league,
    c.name                                                                  AS country,
    COUNT(DISTINCT t.team_api_id)                                           AS total_teams,
    SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END)   AS total_wins,
    ROUND(
        CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
        / NULLIF(COUNT(*), 0) * 100, 2
    )                                                                       AS avg_win_pct
FROM Match m
JOIN Team    t ON m.home_team_api_id = t.team_api_id
JOIN League  l ON m.league_id        = l.id
JOIN Country c ON m.country_id       = c.id
GROUP BY l.name, c.name
ORDER BY avg_win_pct DESC;


-- QUERY 12 (JOIN + VIEW)
-- Which leagues produced the most dominant teams on average?
-- Uses our custom view vw_TeamSeasonPerformance

SELECT
    league,
    country,
    COUNT(DISTINCT team_name) AS total_teams,
    ROUND(AVG(win_percentage), 2) AS avg_win_pct,
    MAX(wins) AS most_wins_in_a_season
FROM vw_TeamSeasonPerformance
GROUP BY league, country
ORDER BY avg_win_pct DESC;


-- QUERY 13 (BONUS JOIN)
-- What was the average number of goals per game each season?
SELECT
    m.season,
    COUNT(*) AS total_matches,
    SUM(m.home_team_goal + m.away_team_goal) AS total_goals,
    ROUND(AVG(CAST(m.home_team_goal + m.away_team_goal AS FLOAT)), 2) AS avg_goals_per_match
FROM Match m
GROUP BY m.season
ORDER BY m.season;
