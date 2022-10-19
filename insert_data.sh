#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games,teams")
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1;")
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1;")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
#FOR TEAMS
if [[ $YEAR != year ]]
then
#IF WINNER IS NOT ON TABLE
TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
if [[ -z $TEAM_ID ]]
then
INSERT_TEAM_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
if [[ $INSERT_TEAM_NAME == "INSERT 0 1" ]]
then 
echo ADDED $WINNER
fi
fi
#IF OPPONENT IS NOT ON TABLE
TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
if [[ -z $TEAM_ID ]]
then
INSERT_TEAM_ID=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
if [[ $INSERT_TEAM_NAME == "INSERT 0 1" ]]
then 
echo ADDED $OPPONENT
fi
fi
#FOR GAMES
#GET WINNER_ID
WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER';")
#GET OPPONENT_ID
OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name ='$OPPONENT';")
#CHECK GAME_ID
GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year = $YEAR AND round = '$ROUND' AND winner_id = $WINNER_ID AND opponent_id = $OPPONENT_ID;")
if [[ -z $GAME_ID ]]
then 
#INSERT GAME_ID
INSERT_GAME_ID=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS);")
if [[ $INSERT_GAME_ID == "INSERT 0 1" ]]
then
echo ADDED $ROUND Match, Year $YEAR, $WINNER vs $OPPONENT
fi
fi
fi
done
