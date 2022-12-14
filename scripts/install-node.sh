#!/bin/bash

# Clear terminal and set PATH
clear
PATH='/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin'

# Play sound and display message on exit
function close_message {
  if [[ "${1}" -ne 0 ]] # Unsuccessful exit
  then
    (&>/dev/null afplay '/System/Library/Sounds/Hero.aiff' &)
    exit "${1}" # Exit with the original error code
  fi

  (&>/dev/null afplay '/System/Library/Sounds/Glass.aiff' &)
  printf '\n\nYOU CAN CLOSE THE TERMINAL\n\n\n'
}

trap 'close_message "$?"' EXIT

# Check for installation
if /usr/bin/which -s node
then
  printf '\nNode is installed at %s\n' "$(which node)"
  node --version
  exit 0
fi

# Check for Homebrew
if ! /usr/bin/which -s brew
then
  printf '\n%s\n%s\n%s\n\n' \
    'Homebrew is required to install dependencies. Insert your password to continue.' \
    "You won't see *** or equivalent. This is normal. Type it and press ↩" \
    'The process can take ≈15 minutes to complete. There will be a sound and a message.'

  # Use sudo with keepalive for the script's duration
  # The default timeout may be too short if the Developer Tools take long to install
  /usr/bin/sudo --validate

  while true
  do
    /usr/bin/sudo --non-interactive true
    sleep 50
    kill -0 "$$" || exit
  done 2> /dev/null &

  # Install Homebrew
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install
printf '\n\n'
brew install node
