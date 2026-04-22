-- ============================================================
-- PROJECT: Top Soccer Teams Progression from 2008 to 2016
-- FILE:    stored_procedure.sql
-- AUTHORS: [Your Name] & Chris
-- DESC:    Stored procedure that accepts a team name and returns
--          its full season-by-season progression, classifying
--          the team as Elite, Competitive, or Struggling based
--          on overall win rate. Uses IF/ELSE logic as required.
-- ============================================================

-- Drop procedure if it already exists (safe re-run)
IF OBJECT_ID('dbo.sp_TeamProgression', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_TeamProgression;
GO

-- ============================================================
-- STORED PROCEDURE: sp_TeamProgression
-- PURPOSE: Given a team name, returns:
--            1. Season-by-season performance breakdown
--            2. An overall classification (Elite / Competitive / Struggling)
--               based on the team's average win rate across all seasons
-- PARAMETER: @TeamName VARCHAR(100) — full team name (e.g. 'FC Barcelona')
-- ============================================================
CREATE PROCEDURE sp_TeamProgression
    @TeamName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Calculate the team's overall win rate across all seasons
    DECLARE @OverallWinRate FLOAT;

    SELECT @OverallWinRate =
        ROUND(
            CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
            / NULLIF(COUNT(*), 0) * 100, 2
        )
    FROM Match m
    JOIN Team t ON m.home_team_api_id = t.team_api_id
    WHERE t.team_long_name = @TeamName;

    -- Step 2: Classify the team using IF/ELSE based on win rate
    IF @OverallWinRate IS NULL
    BEGIN
        PRINT 'Team not found. Please check the team name and try again.';
        RETURN;
    END
    ELSE IF @OverallWinRate >= 60
    BEGIN
        PRINT '======================================';
        PRINT 'TEAM: ' + @TeamName;
        PRINT 'OVERALL WIN RATE: ' + CAST(@OverallWinRate AS VARCHAR(10)) + '%';
        PRINT 'CLASSIFICATION: *** ELITE TIER ***';
        PRINT 'This team was among the dominant forces in European football (2008-2016).';
        PRINT '======================================';
    END
    ELSE IF @OverallWinRate >= 45
    BEGIN
        PRINT '======================================';
        PRINT 'TEAM: ' + @TeamName;
        PRINT 'OVERALL WIN RATE: ' + CAST(@OverallWinRate AS VARCHAR(10)) + '%';
        PRINT 'CLASSIFICATION: -- COMPETITIVE TIER --';
        PRINT 'This team was consistently competitive but did not dominate their league.';
        PRINT '======================================';
    END
    ELSE
    BEGIN
        PRINT '======================================';
        PRINT 'TEAM: ' + @TeamName;
        PRINT 'OVERALL WIN RATE: ' + CAST(@OverallWinRate AS VARCHAR(10)) + '%';
        PRINT 'CLASSIFICATION: STRUGGLING TIER';
        PRINT 'This team spent most of this period in the lower half of their league.';
        PRINT '======================================';
    END

    -- Step 3: Return the full season-by-season breakdown as a result set
    SELECT
        m.season,
        COUNT(*)                                                                AS total_matches,
        SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END)   AS wins,
        SUM(CASE WHEN m.home_team_goal = m.away_team_goal THEN 1 ELSE 0 END)   AS draws,
        SUM(CASE WHEN m.home_team_goal < m.away_team_goal THEN 1 ELSE 0 END)   AS losses,
        SUM(m.home_team_goal)                                                   AS goals_scored,
        SUM(m.away_team_goal)                                                   AS goals_conceded,
        ROUND(
            CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) AS FLOAT)
            / NULLIF(COUNT(*), 0) * 100, 2
        )                                                                       AS win_pct
    FROM Match m
    JOIN Team t ON m.home_team_api_id = t.team_api_id
    WHERE t.team_long_name = @TeamName
    GROUP BY m.season
    ORDER BY m.season ASC;
END;
GO

-- ============================================================
-- HOW TO RUN THE STORED PROCEDURE
-- Try these teams to showcase different classifications:
-- ============================================================

-- Elite example:
EXEC sp_TeamProgression 'FC Barcelona';

-- Competitive example:
EXEC sp_TeamProgression 'Everton';

-- Struggling example:
EXEC sp_TeamProgression 'Bury';
GO
