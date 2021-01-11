


alter PROC sp_getStandingsUpToDate
	@aDate date
AS
BEGIN

	IF(@aDate<'2013-08-16' OR @aDate>'2014-07-31')
	BEGIN
		raiserror('Invalid date!', 16, 1)
	END

	ELSE
	BEGIN
		DECLARE @TeamID smallint SET @TeamID=1
		
		WHILE @TeamID<=(SELECT COUNT(teamID) FROM team)
		BEGIN
		DECLARE @win smallint SET @win=0
		DECLARE @tie smallint SET @tie=0
		DECLARE @lose smallint SET @lose=0
		DECLARE @goalsForward smallint SET @goalsForward=0 
		DECLARE @goalsAgainst smallint SET @goalsAgainst=0
		DECLARE @point smallint SET @point=0
		DECLARE @homeTeam smallint SET @homeTeam=0
		DECLARE @visitingTeam smallint SET @visitingTeam =0
		DECLARE @currentTeam smallint SET @currentTeam=@TeamID
		DECLARE @TeamName nvarchar(50)
		DECLARE @HomeTeamGoal smallint set @HomeTeamGoal=0
		DECLARE @VisitingTeamGoal smallint set @VisitingTeamGoal=0
		DECLARE @MatchID int SET @MatchID=1
		
		
		WHILE @MatchID<= (SELECT COUNT(matchID) FROM match)
		BEGIN
			SELECT @HomeTeamGoal = COUNT(*) 
			FROM Match m inner join Goals g on m.matchID=g.matchID 
			              inner join PlayerTeam pt on pt.teamID=m.homeTeamID						  
			WHERE g.IsOwnGoal=0 AND pt.playerID=g.playerID AND m.matchID=@MatchID
				   AND pt.season='13-14' AND m.dateOfMatch < @aDate
			GROUP BY m.matchID

			SELECT @HomeTeamGoal = COUNT(*) 
			FROM Match m inner join Goals g on m.matchID=g.matchID 
			              inner join PlayerTeam pt on pt.teamID=m.VisitingTeamID						  
			WHERE g.IsOwnGoal=1 AND pt.playerID=g.playerID AND m.matchID=@MatchID
				   AND pt.season='13-14' AND m.dateOfMatch < @aDate
			GROUP BY m.matchID

			SELECT @VisitingTeamGoal = COUNT(*) 
			FROM Match m inner join Goals g on m.matchID=g.matchID 
			              inner join PlayerTeam pt on pt.teamID=m.VisitingTeamID						  
			WHERE g.IsOwnGoal=0 AND pt.playerID=g.playerID AND m.matchID=@MatchID
				   AND pt.season='13-14' AND m.dateOfMatch < @aDate
			GROUP BY m.matchID

			SELECT @VisitingTeamGoal = COUNT(*) 
			FROM Match m inner join Goals g on m.matchID=g.matchID 
			              inner join PlayerTeam pt on pt.teamID=m.HomeTeamID						  
			WHERE g.IsOwnGoal=1 AND pt.playerID=g.playerID AND m.matchID=@MatchID
				   AND pt.season='13-14' AND m.dateOfMatch < @aDate
			GROUP BY m.matchID
		SET @MatchID+=1
		END 

		UPDATE StandingsTable
		Set GP = (HT.MatchPlayed+VT.MatchPlayed)
		From (Select th.TeamID, Count(*) MatchPlayed
			  From Match m inner join Team th on m.HomeTeamID=th.TeamID
			  Where m.DateOfMatch<=@aDate
		      Group By th.TeamID) HT

			  inner join Team t on HT.TeamID=t.TeamID

			  inner join (Select tv.TeamID, Count(*) MatchPlayed
			  From Match m inner join Team tv on m.VisitingTeamID=tv.TeamID
			  Where m.DateOfMatch<=@aDate
			  Group By tv.TeamID) VT    on VT.TeamID=t.TeamID

		SET @TeamName = (Select t.Name FROM Team t Where t.TeamID=@currentTeam)
			
		INSERT INTO StandingsTable (TName, W, T, L, GF, GA, GD, Pts)
		VALUES (@TeamName, @win, @tie, @lose, @goalsForward, @goalsAgainst, (@goalsForward-@goalsAgainst), @point)

		SET @TeamID+=1
	END

		SELECT RANK() OVER (ORDER BY StandingsTable.Pts desc, StandingsTable.GD desc, StandingsTable.GF desc) AS Pos, *
		FROM StandingsTable
	END
END

CREATE TABLE StandingsTable(TName nvarchar(50), GP smallint, W smallint, T smallint, L smallint, GF smallint, GA smallint, GD smallint, Pts smallint)

exec sp_getStandingsUpToDate '2014-07-31'
