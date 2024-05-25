#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


MAIN_MENU() {

  # taking a new username
  echo "Enter your username:"
  read USERNAME

  # username query
  USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
  
  # checking if it's exist in DB
  if [[ -z $USERNAME_RESULT ]]
  then
    # creating new user
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_NEW_USER=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
    USERNAME_RESULT=$USERNAME
  else
    
    # getting user data from DB

    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")

    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")

    echo "Welcome back, $USERNAME_RESULT! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  # playing new game

  # Generate a random number within 1 - 1000
  NUMBER_TO_GUESS=$((1 + RANDOM % 1000))
  echo "Guess the secret number between 1 and 1000:"
  COUNT=0

  while true; do

    read GUESS

    # checking if the guess true or not
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      ((COUNT=COUNT+1))
    elif [[ $GUESS -lt $NUMBER_TO_GUESS ]]
    then
      echo "It's higher than that, guess again:"
      ((COUNT=COUNT+1))
    elif [[ $GUESS -gt $NUMBER_TO_GUESS ]]
    then
      echo "It's lower than that, guess again:"
      ((COUNT=COUNT+1))
    else
      ((COUNT=COUNT+1))
      echo "You guessed it in $COUNT tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
      break
    fi
  done

  # update user's game data

  # games_played + 1
  GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME_RESULT'")
    
  #check the best_game
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME_RESULT'")

  # update if it's not updated yet or there was a new score
  if [[ $BEST_GAME -eq 0 || $BEST_GAME -gt $COUNT ]]
  then
    BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $COUNT WHERE username = '$USERNAME_RESULT'")
  fi

}

MAIN_MENU