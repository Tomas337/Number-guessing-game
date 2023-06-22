#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USERNAME_RESPONSE=$($PSQL "SELECT * FROM players WHERE username='$USERNAME'")

if [[ ! -z $USERNAME_RESPONSE ]]
then
  IFS="|" read -ra USER <<< "$USERNAME_RESPONSE"
  echo "Welcome back, ${USER[0]}! You have played ${USER[1]} games, and your best game took ${USER[2]} guesses."
  #echo "Welcome back, $(echo ${USER[0]} | sed -E 's/^ +| +$//')! You have played $(echo ${USER[1]} | sed -E 's/^ +| +$//') games, and your best game took $(echo ${USER[2]} | sed -E 's/^ +| +$//') guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_RESULT=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
fi

GENERATED_NUMBER=(1 + $RANDOM % 1000)

echo "Guess the secret number between 1 and 1000:"

NUMBER_OF_GUESSES=0

while true
do
  read NUMBER
  if [[ ! $NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))

  if [[ $NUMBER -eq $GENERATED_NUMBER ]]
  then
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $GENERATED_NUMBER. Nice job!"
    break
  fi
  if [[ $NUMBER -gt $GENERATED_NUMBER ]]
  then  
    echo "It's lower than that, guess again:"
    continue
  fi
  if [[ $NUMBER -lt $GENERATED_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    continue
  fi
done

USERNAME_RESPONSE=$($PSQL "SELECT * FROM players WHERE username='$USERNAME'")
IFS="|" read -ra USER <<< "$USERNAME_RESPONSE"

GAMES_PLAYED_INCREMENT=$(( ${USER[1]} + 1 ))
GAMES_PLAYED_UPDATE=$($PSQL "UPDATE players SET games_played=$GAMES_PLAYED_INCREMENT WHERE username='$USERNAME'")

if [[ $NUMBER_OF_GUESSES -lt ${USER[2]} || ${USER[2]} -eq 0 ]]
then
  NUMBER_OF_GUESSES_UPDATE=$($PSQL "UPDATE players SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
fi
