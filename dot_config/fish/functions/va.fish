function va --description 'Activate the Python virtual environment from .venvdir'
  # Check for .venvdir, if it's not there prompt the user to choose a name
  # (blank entry will exit)
  if not test -f .venvdir
    echo "No .venvdir file found. Please create one with the name of your virtual environment."
    echo "Enter the name of your virtual environment (or press Enter to exit):"
    read -l name
    if test -z "$name"
      echo "Exiting without creating a virtual environment."
      return 1
    end

    # Create .venvdir with the provided name
    echo $name > .venvdir
    echo "Created .venvdir with name '$name'."
  else
    echo ".venvdir found, proceeding to activate the virtual environment."
  end

  # Read the virtual environment name from .venvdir
  set -l name (string trim (cat .venvdir))
  set -l venv_root $HOME/venv
  set -l venv_path $venv_root/$name

  # Create the virtual environment if it does not exist
  if not test -d $venv_path
    echo "Creating virtual environment '$venv_path'..."
    python3 -m venv $venv_path
    if test $status -ne 0
      echo "Error: Failed to create virtual environment '$venv_path'."
      return 1
    end
  end

  # Activate the virtual environment
  if test -f $venv_path/bin/activate.fish
    source $venv_path/bin/activate.fish
  else if test -f $venv_path/bin/activate
    source $venv_path/bin/activate
  else
    echo "Error: No activation script found in $venv_path/bin."
    return 1
  end

  echo "Activated virtual environment '$venv_path'."
end
