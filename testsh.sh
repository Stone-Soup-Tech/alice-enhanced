NEW_VERSION="0.9.8"
IFS='.' read -ra versionArray <<< "$NEW_VERSION"

if [[ "${versionArray[2]}" == "9" ]]; then
  versionArray[2]="0"
  if [[ "${versionArray[1]}" == "9" ]]; then
    versionArray[1]="0"
    versionArray[0]="$((${versionArray[0]} + 1))"
  else
    versionArray[1]="$((${versionArray[1]} + 1))"
  fi
else
  versionArray[2]="$((${versionArray[2]} + 1))"
fi

IFS='.';NEW_VERSION="${versionArray[*]}";IFS=$' \t\n'
echo $NEW_VERSION