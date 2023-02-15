#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE games,teams")"
i=0
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
  #Agregar un contador
  i=$((i+1))
  #Agregar los equipos individualmente a nuestra data base
    WINNER_TEAM="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') ON CONFLICT DO NOTHING")"
    OPPONENT_TEAM="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') ON CONFLICT DO NOTHING")"

    if [[ $WINNER_TEAM == 'INSERT 0 1' ]]
    then
      if [[ $OPPONENT_TEAM == 'INSERT 0 1' ]]
      then
        echo "Teams $WINNER, $OPPONENT inserted."
      else
        echo "$WINNER team inserted."
      fi
    else [[ $OPPONENT_TEAM == 'INSERT 0 1' ]]
      echo "$OPPONENT team inserted."
    fi
  
  #Obtener los ID de cada equipo
    WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
    OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"

  #Agregar todos los demas datos en la tabla games con el ID de cada equipo
    GAME="$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR','$ROUND',$WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")"
    echo "Game $i: $WINNER vs $OPPONENT - $YEAR inserted"
    
  fi
done