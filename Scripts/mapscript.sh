#!/bin/bash

# Replace with your actual API key
API_KEY="AIzaSyAwQmz4CDx0vsnFtOMVafXN35EXUEyf6Tk"

# Function to encode the address for URL
urlencode() {
  local string="${1// /%20}"
  echo "$string"
}

# Output file
output_file="output2.csv"

# Create or clear the output file
echo "Address, Latitude, Longitude" > "$output_file"

# Read addresses from addresses.txt and process each one
while IFS= read -r address || [[ -n "$address" ]]; do
  # Trim leading and trailing spaces from the address
  trimmed_address=$(echo "$address" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  
  # URL encode the address
  encoded_address=$(urlencode "$trimmed_address")

  # Make a request to the Google Maps Geocoding API and save the response to a file
  response_file="geocoding_response.json"
  curl -s "https://maps.googleapis.com/maps/api/geocode/json?address=$encoded_address&key=$API_KEY" -o "$response_file"

  # Check if the response contains an error
  if grep -q '"error_message"' "$response_file"; then
    echo "Error geocoding address: $trimmed_address"
    continue
  fi

  # Extract latitude, longitude, and formatted address from the response
  latitude=$(grep -o '"lat" : [0-9.-]*' "$response_file" | head -n1 | awk -F ': ' '{print $2}')
  longitude=$(grep -o '"lng" : [0-9.-]*' "$response_file" | head -n1 | awk -F ': ' '{print $2}')
  formatted_address=$(grep -o '"formatted_address" : "[^"]*"' "$response_file" | head -n1 | awk -F ': "' '{print $2}' | sed 's/"//g')

  # Save the results to the output file
  echo "\"$formatted_address\", $latitude, $longitude" >> "$output_file"

  echo "Geocoded address: $formatted_address"
done < addresses.txt

echo "Output saved to $output_file"
