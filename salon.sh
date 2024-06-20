#!/bin/bash

# Connect to the database
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Function to display the list of services
DISPLAY_SERVICES() {
  echo -e "\nAvailable Services:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

# Function to get customer information
GET_CUSTOMER_INFO() {
  # Get the customer's phone number
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE

  # Check if the customer exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    # If the customer does not exist, get their name
    echo -e "\nIt looks like you are a new customer. Please enter your name:"
    read CUSTOMER_NAME

    # Insert the new customer into the customers table
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  else
    # Remove leading/trailing whitespace
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/ |//g')
  fi
}

# Function to create an appointment
CREATE_APPOINTMENT() {
  # Prompt for service_id
  while [[ -z $SERVICE_ID_SELECTED ]]
  do
    echo -e "\nPlease enter the service_id for the service you want:"
    read SERVICE_ID_SELECTED

    # Validate service_id
    VALID_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    if [[ -z $VALID_SERVICE ]]
    then
      echo -e "\nInvalid service ID. Please select from the list below:"
      DISPLAY_SERVICES
      SERVICE_ID_SELECTED=""
    fi
  done

  # Get customer information
  GET_CUSTOMER_INFO

  # Prompt for service time
  echo -e "\nPlease enter the time you would like the service:"
  read SERVICE_TIME

  # Get the customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Insert the appointment into the appointments table
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Get the service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  # Remove leading/trailing whitespace
  SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/ |//g')

  # Confirmation message
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

# Main script execution
DISPLAY_SERVICES
CREATE_APPOINTMENT
