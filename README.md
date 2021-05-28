### 2021 Cincinnati Reds Quantitative Developer Trainee Questionnaire
---
1. Please use the data provided to complete this task.  Please be sure to include any code produced in your final response document.
    - Create a single page pitcher summary report or dashboard that can be produced for any PITCHER_ID.
    - Produce your output for PITCHER_ID’s 62, 149, and 512. Include this output in your final response document.

	[Pitcher Summary Report](https://spencerharrison.shinyapps.io/Pitcher-Summary-Report)
	
	[Reports for Specified IDs](reports/)

2. Please select one piece of public research you have read in recent months that you found interesting and applicable to a Major League coaching staff.  Write a one-paragraph summary on that article that would be appropriate to send to an entire Major League coaching staff and analytics department.

3. Suppose you have two SQL tables with the following data for seasons 2010 to current (column names in parentheses):
    - **TEAM** contains team-specific information (SEASON, TEAM_ID, TEAM_NAME, ORGANIZATION_ID, ORGANIZATION_NAME, LEVEL_NAME, LEAGUE_NAME) 
    - **STATS** contains team hitting statistics (GAME_ID, GAME_DATE, BATTER_TEAM_ID, BATTER_ID, INNING, PA, AB, ER, H, 1B, 2B, 1B, 2B, 3B, HR, SB, CS, CS, BB, SO, IBB, HBP, SF, SH)

        Write a sample SQL query to return Fielding Independent Pitching (FIP) constants for the 2019 season by affiliate level and league.
		
		```
		SELECT
			t.LEVEL_NAME,
			t.LEAGUE_NAME,
			SUM(s.ER) as lgER,
			SUM((CASE WHEN s.PA = 1 AND s.H = 0 AND s.BB = 0 AND s.IBB = 0 AND s.HBP = 0 THEN 1 ELSE 0 END) +
					CASE WHEN s.CS = 1 THEN 1 ELSE 0 END) as lgOuts,
			SUM(s.HR) as lgHR,
			SUM(s.BB + s.IBB) as lgBB,
			SUM(s.HBP) as lgHBP,
			SUM(s.SO) as lgK
		INTO #FIPdata
		FROM STATS s
		INNER JOIN TEAM t
			ON YEAR(s.GAME_DATE) = t.SEASON
			AND s.BATTER_TEAM_ID = t.TEAM_ID
		WHERE t.SEASON = 2019
		GROUP BY
			t.LEVEL_NAME,
			t.LEAGUE_NAME
	
		SELECT
			LEVEL_NAME,
			LEAGUE_NAME,
			((lgER * 9) / (1.0 * lgOuts / 3)) - (((13 * lgHR) + (3 * (lgBB + lgHBP)) - (2 * lgK)) / (1.0 * lgOuts / 3)) as FIP_Constant
		FROM #FIPdata

		DROP TABLE IF EXISTS #FIPdata```

4. What player development technology do you feel is the most valuable for an organization to leverage and why? Please limit your response to one paragraph.