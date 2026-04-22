-- ============================================================
-- PROJECT: Top Soccer Teams Progression from 2008 to 2016
-- FILE:    view.sql
-- AUTHORS: [Your Name] & Chris
-- DESC:    Creates a reusable view summarizing team performance
--          per season. Used across multiple queries in the project.
-- ============================================================

-- Drop view if it already exists (safe re-run)
IF OBJECT_ID('dbo.vw_TeamSeasonPerformance', 'V') IS NOT NULL
    DROP VIEW dbo.vw_TeamSeasonPerformance;
GO

-- ============================================================
-- VIEW: vw_TeamSeasonPerformance
-- PURPOSE: Aggregates each team's home match results per season,
--          providing wins, draws, losses, goals scored/conceded,
--          and win percentage. Used as the base for most queries.
-- ============================================================
CREATE VIEW vw_TeamSeasonPerformance AS
SELECT
    t.team_long_name                                                    AS team_name,
    t.team_short_name                                                   AS team_abbr,
    l.name                                                              AS league,
    c.name                                                              AS country,
    m.season,

    COUNT(*)                                                            AS total_matches,

    SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END)  AS wins,
    SUM(CASE WHEN m.home_team_goal = m.away_team_goal THEN 1 ELSE 0 END)  AS draws,
    SUM(CASE WHEN m.home_team_goal < m.away_team_goal THEN 1 ELSE 0 END)  AS losses,

    SUM(m.home_team_goal)                                               AS goals_scored,
    SUM(m.away_team_goal)                                               AS goals_conceded,
    SUM(m.home_team_goal) - SUM(m.away_team_goal)                      AS goal_difference,

    ROUND(
        CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
        / NULLIF(COUNT(*), 0) * 100, 2
    )                                                                   AS win_percentage

FROM Match m
JOIN Team    t ON m.home_team_api_id = t.team_api_id
JOIN League  l ON m.league_id        = l.id
JOIN Country c ON m.country_id       = c.id

GROUP BY
    t.team_long_name,
    t.team_short_name,
    l.name,
    c.name,
    m.season;
GO

-- ============================================================
-- TEST THE VIEW
-- Run this after creating the view to verify it works:
-- ============================================================
SELECT TOP 20 *
FROM vw_TeamSeasonPerformance
ORDER BY win_percentage DESC;
GO
