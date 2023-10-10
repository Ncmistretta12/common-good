# CSV file to store the extracted data
csv_file="output.csv"

# Clear the CSV file (if exists)
> "${csv_file}"

while IFS= read -r bbl; do
# Loop through PIN numbers
    output_file="${bbl}.txt"

    # Download the webpage content
    curl -k "https://a836-pts-access.nyc.gov/CARE/Datalets/PrintDatalet.aspx?pin=${bbl}&gsp=PROFILEALL2&taxyear=2024&jur=65&ownseq=0&card=1&roll=RP_NY&State=1&item=1&items=-1&all=undefined&ranks=Datalet" -o "${output_file}"

    # Extract profile owner information using grep and sed
    profile_owner=$(grep -A 1 "PROFILE_OWNERS" "${output_file}" | grep "DataletData" | sed 's/<[^>]*>//g')
echo ${profile_owner}
    if [ -n "${profile_owner}" ]; then
        echo "${bbl},${profile_owner}" >> "${csv_file}"
        echo "Profile owner data for PIN ${bbl} appended to ${csv_file}"
    else
        echo "Profile owner data for PIN ${bbl} not found"
    fi
done < bbllist.txt
    # Clean up temporary files
    rm -f "${output_file}"
