-- 12 Queries
-- QUERY 1: Rank all teams by total wins across all seasons (2008-2016).
--          This gives us our overall Top 10 most dominant teams.
-- ============================================================
SELECT TOP 10
    t.team_long_name                                                        AS team,
    l.name                                                                  AS league,
    COUNT(m.id, m.country_id, m.league_id, m.season, m.stage, m.date, m.match_api_id, m.home_team_api_id, m.away_team_api_id, m.home_team_goal, m.away_team_goal, m.home_player_X1, m.home_player_X2, m.home_player_X3, m.home_player_X4, m.home_player_X5, m.home_player_X6, m.home_player_X7, m.home_player_X8, m.home_player_X9, m.home_player_X10, m.home_player_X11, m.away_player_X1, m.away_player_X2, m.away_player_X3, m.away_player_X4, m.away_player_X5, m.away_player_X6, m.away_player_X7, m.away_player_X8, m.away_player_X9, m.away_player_X10, m.away_player_X11, m.home_player_Y1, m.home_player_Y2, m.home_player_Y3, m.home_player_Y4, m.home_player_Y5, m.home_player_Y6, m.home_player_Y7, m.home_player_Y8, m.home_player_Y9, m.home_player_Y10, m.home_player_Y11, m.away_player_Y1, m.away_player_Y2, m.away_player_Y3, m.away_player_Y4, m.away_player_Y5, m.away_player_Y6, m.away_player_Y7, m.away_player_Y8, m.away_player_Y9, m.away_player_Y10, m.away_player_Y11, m.home_player_1, m.home_player_2, m.home_player_3, m.home_player_4, m.home_player_5, m.home_player_6, m.home_player_7, m.home_player_8, m.home_player_9, m.home_player_10, m.home_player_11, m.away_player_1, m.away_player_2, m.away_player_3, m.away_player_4, m.away_player_5, m.away_player_6, m.away_player_7, m.away_player_8, m.away_player_9, m.away_player_10, m.away_player_11, m.goal, m.shoton, m.shotoff, m.foulcommit, m.card, m.cross, m.corner, m.possession, m.B365H, m.B365D, m.B365A, m.BWH, m.BWD, m.BWA, m.IWH, m.IWD, m.IWA, m.LBH, m.LBD, m.LBA, m.PSH, m.PSD, m.PSA, m.WHH, m.WHD, m.WHA, m.SJH, m.SJD, m.SJA, m.VCH, m.VCD, m.VCA, m.GBH, m.GBD, m.GBA, m.BSH, m.BSD, m.BSA, t.id, t.team_api_id, t.team_fifa_api_id, t.team_long_name, t.team_short_name, l.id, l.country_id, l.name)                                                                AS total_matches,
    SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END)   AS total_wins,
    ROUND(
        CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
        / NULLIF(COUNT(*), 0) * 100, 2
    )                                                                       AS win_pct
FROM Match m
JOIN Team   t ON m.home_team_api_id = t.team_api_id
JOIN League l ON m.league_id        = l.id
GROUP BY t.team_long_name, l.name
ORDER BY total_wins DESC;


-- ============================================================
-- QUERY 2 (JOIN): Show total goals scored vs. goals conceded per team,
--          identifying the best attacking and defensive teams
--          across all 8 seasons.
-- ============================================================
SELECT TOP 15
    t.team_long_name                    AS team,
    SUM(m.home_team_goal)               AS goals_scored,
    SUM(m.away_team_goal)               AS goals_conceded,
    SUM(m.home_team_goal)
        - SUM(m.away_team_goal)         AS goal_difference
FROM Match m
JOIN Team t ON m.home_team_api_id = t.team_api_id
GROUP BY t.team_long_name
ORDER BY goal_difference DESC;


-- ============================================================
-- QUERY 3 (JOIN): Compare home wins vs. away wins for the top teams,
--          measuring the strength of home field advantage.
-- ============================================================
SELECT TOP 10
    t.team_long_name AS team,

    -- Home performance
    SUM(CASE WHEN m.home_team_api_id = t.team_api_id
             AND m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS home_wins,

    -- Away performance (when team is the away team)
    SUM(CASE WHEN m.away_team_api_id = t.team_api_id
             AND m.away_team_goal > m.home_team_goal THEN 1 ELSE 0 END) AS away_wins,

    -- Total wins combined
    SUM(CASE WHEN m.home_team_api_id = t.team_api_id
             AND m.home_team_goal > m.away_team_goal THEN 1
             WHEN m.away_team_api_id = t.team_api_id
             AND m.away_team_goal > m.home_team_goal THEN 1
             ELSE 0 END)                                                 AS total_wins

FROM Match m
JOIN Team t ON m.home_team_api_id = t.team_api_id
           OR m.away_team_api_id  = t.team_api_id
GROUP BY t.team_long_name, t.team_api_id
ORDER BY total_wins DESC;


-- ============================================================
-- QUERY 4 (JOIN): Season-by-season win count for the Top 5 most
--          winning teams, showing their progression over time.
--          Core query for our main visualization.
-- ============================================================
SELECT
    t.team_long_name    AS team,
    m.season,
    SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS wins
FROM Match m
JOIN Team t ON m.home_team_api_id = t.team_api_id
WHERE t.team_long_name IN (
    'FC Barcelona', 'Real Madrid CF', 'Juventus', 'FC Bayern Munich', 'Chelsea'
)
GROUP BY t.team_long_name, m.season
ORDER BY t.team_long_name, m.season;


-- ============================================================
-- QUERY 5 (JOIN): Identify teams with the best consistency — those
--          who maintained a high win rate across EVERY season,
--          not just a few standout years.
-- ============================================================
SELECT
    t.team_long_name    AS team,
    m.season,
    COUNT(*)            AS matches_played,
    SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS wins,
    ROUND(
        CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
        / NULLIF(COUNT(*), 0) * 100, 2
    )                   AS win_pct
FROM Match m
JOIN Team t ON m.home_team_api_id = t.team_api_id
WHERE t.team_long_name IN (
    'FC Barcelona', 'Real Madrid CF', 'Juventus', 'FC Bayern Munich', 'Chelsea'
)
GROUP BY t.team_long_name, m.season
ORDER BY t.team_long_name, m.season;


-- ============================================================
-- QUERY 6 (JOIN + CASE): Classify each team's season result as
--          'Dominant', 'Good', 'Average', or 'Poor'
--          based on their win percentage that season.
-- ============================================================
SELECT
    t.team_long_name    AS team,
    m.season,
    COUNT(*)            AS matches,
    SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS wins,
    ROUND(
        CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
        / NULLIF(COUNT(*), 0) * 100, 2
    )                   AS win_pct,

    CASE
        WHEN ROUND(CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
             / NULLIF(COUNT(*), 0) * 100, 2) >= 70 THEN 'Dominant'
        WHEN ROUND(CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
             / NULLIF(COUNT(*), 0) * 100, 2) >= 55 THEN 'Good'
        WHEN ROUND(CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
             / NULLIF(COUNT(*), 0) * 100, 2) >= 40 THEN 'Average'
        ELSE 'Poor'
    END                 AS season_classification

FROM Match m
JOIN Team t ON m.home_team_api_id = t.team_api_id
GROUP BY t.team_long_name, m.season
ORDER BY t.team_long_name, m.season;


-- ============================================================
-- QUERY 7 (JOIN + GROUP BY + HAVING): Find teams that achieved a win rate above 60%
--          in at least one season — the true elite performers.
--          Uses HAVING to filter aggregated results.
-- ============================================================
SELECT
    t.team_long_name    AS team,
    m.season,
    COUNT(*)            AS matches,
    SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS wins,
    ROUND(
        CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
        / NULLIF(COUNT(*), 0) * 100, 2
    )                   AS win_pct
FROM Match m
JOIN Team t ON m.home_team_api_id = t.team_api_id
GROUP BY t.team_long_name, m.season
HAVING ROUND(
        CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
        / NULLIF(COUNT(*), 0) * 100, 2
       ) >= 60
ORDER BY win_pct DESC;


-- ============================================================
-- QUERY 8 (VARIABLES): Analyze performance for a specific declared season.
--          Change @TargetSeason to explore any year.
--          Demonstrates T-SQL variables.
-- ============================================================
DECLARE @TargetSeason VARCHAR(10) = '2015/2016';

SELECT TOP 10
    t.team_long_name    AS team,
    l.name              AS league,
    COUNT(*)            AS matches,
    SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS wins,
    SUM(m.home_team_goal)                                                  AS goals_scored,
    ROUND(
        CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
        / NULLIF(COUNT(*), 0) * 100, 2
    )                   AS win_pct
FROM Match m
JOIN Team   t ON m.home_team_api_id = t.team_api_id
JOIN League l ON m.league_id        = l.id
WHERE m.season = @TargetSeason
GROUP BY t.team_long_name, l.name
ORDER BY wins DESC;


-- ============================================================
-- QUERY 9 (SUBQUERY): Find teams whose overall win rate is higher than
--          the European average win rate across all teams.
--          Uses a subquery to calculate the average benchmark.
-- ============================================================
SELECT
    t.team_long_name    AS team,
    COUNT(*)            AS matches,
    SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS wins,
    ROUND(
        CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
        / NULLIF(COUNT(*), 0) * 100, 2
    )                   AS win_pct
FROM Match m
JOIN Team t ON m.home_team_api_id = t.team_api_id
GROUP BY t.team_long_name, t.team_api_id
HAVING ROUND(
        CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
        / NULLIF(COUNT(*), 0) * 100, 2
       ) >
       (
           -- Subquery: European average win rate across all teams
           SELECT ROUND(
               CAST(SUM(CASE WHEN home_team_goal > away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
               / NULLIF(COUNT(*), 0) * 100, 2
           )
           FROM Match
       )
ORDER BY win_pct DESC;


-- ============================================================
-- QUERY 10 (CTE): Use a Common Table Expression to calculate each
--          team's win rate per season, then show the year-over-year
--          progression for the Top 5 teams. Highlights rises and dips.
-- ============================================================
WITH SeasonStats AS (
    SELECT
        t.team_long_name                                                        AS team,
        m.season,
        COUNT(*)                                                                AS matches,
        SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END)   AS wins,
        ROUND(
            CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
            / NULLIF(COUNT(*), 0) * 100, 2
        )                                                                       AS win_pct
    FROM Match m
    JOIN Team t ON m.home_team_api_id = t.team_api_id
    GROUP BY t.team_long_name, m.season
),
TopTeams AS (
    SELECT TOP 5 team, SUM(wins) AS total_wins
    FROM SeasonStats
    GROUP BY team
    ORDER BY total_wins DESC
)
SELECT
    ss.team,
    ss.season,
    ss.matches,
    ss.wins,
    ss.win_pct
FROM SeasonStats ss
JOIN TopTeams tt ON ss.team = tt.team
ORDER BY ss.team, ss.season;


-- ============================================================
-- QUERY 11 (JOIN + Team_Attributes): Show how top teams' FIFA build-up speed and defense
--          pressure attributes changed over time, linking
--          playing style to match results.
-- ============================================================
SELECT
    t.team_long_name                AS team,
    YEAR(ta.date)                   AS year,
    ta.buildUpPlaySpeed             AS attack_speed,
    ta.chanceCreationShooting       AS shooting_chance,
    ta.defencePressure              AS defence_pressure,
    ta.defenceAggression            AS defence_aggression
FROM Team_Attributes ta
JOIN Team t ON ta.team_api_id = t.team_api_id
WHERE t.team_long_name IN (
    'FC Barcelona', 'Real Madrid CF', 'Juventus', 'FC Bayern Munich', 'Chelsea'
)
ORDER BY t.team_long_name, year;


-- ============================================================
-- QUERY 12 (JOIN + VIEW): Use our custom view (vw_TeamSeasonPerformance) to find
--          which league produced the most top-performing teams
--          on average, showing Europe-wide competition levels.
-- ============================================================
SELECT
    league,
    country,
    COUNT(DISTINCT team_name)       AS total_teams,
    ROUND(AVG(win_percentage), 2)   AS avg_win_pct,
    ROUND(AVG(goals_scored), 2)     AS avg_goals_scored,
    MAX(win_percentage)             AS best_team_win_pct
FROM vw_TeamSeasonPerformance
GROUP BY league, country
ORDER BY avg_win_pct DESC;


-- ============================================================
-- QUERY 13 (BONUS — JOIN + Aggregate): Track average goals scored per season across all
--          top teams to see if European football became more
--          or less attacking from 2008 to 2016.
-- ============================================================
SELECT
    m.season,
    ROUND(AVG(CAST(m.home_team_goal + m.away_team_goal AS FLOAT)), 2) AS avg_goals_per_match,
    SUM(m.home_team_goal + m.away_team_goal)                           AS total_goals,
    COUNT(*)                                                           AS total_matches
FROM Match m
GROUP BY m.season
ORDER BY m.season;
