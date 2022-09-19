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
if /usr/bin/which -s python
then
  # Check if not Python2
  if [[ "$(python --version 2>&1 | awk -F'[. ]' '{ print $2 }')" -ne 2 ]]
  then
    printf '\n%s %s %s\n%s\n%s\n\n' \
      'Python is installed at' "$(which python)" 'but it is not Python2!' \
      'For assistance, ask on https://alfredforum.com/' \
      'Provide the following information:' \

    which python
    python --version
    exit 1
  fi

  printf '\nPython2 is installed at %s\n' "$(which python)"
  python --version
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
brew install pyenv
pyenv versions | grep --quiet '2.7.18' || pyenv install 2.7.18
eval "$(brew shellenv)"
ln -s "${HOME}/.pyenv/versions/2.7.18/bin/python2.7" "${HOMEBREW_PREFIX}/bin/python"
