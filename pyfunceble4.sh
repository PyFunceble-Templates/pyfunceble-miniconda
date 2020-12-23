#!/usr/bin/env bash
# All initial credits to @mitchellkrogza and @funilrys
# Modified by @spirillen
# License: https://www.mypdns.org/w/license/
# Issues: https://www.mypdns.org/maniphest/
# Project: https://www.mypdns.org/project/profile/5/
# -------------------------------
# Setup Conda Python Environments
# -------------------------------

# Stop on any error
set -e #-x

pkgs="tree"
if ! dpkg -s $pkgs >/dev/null 2>&1; then
  sudo apt-get install $pkgs
fi

# Run this script by appending test-file to the script name in the shell prompt
# E.g. miniconda_pyfunceble.sh "/full/path/to/file"

# just a bit of fun
echo -e "\tI'm your hungry cheese missing a piece..."
echo -e "\tAre you ready to go hunting the red pills"
echo -e "\tso we can hunt down evil ghosts"
echo ""
echo -e "\tAre you ready to start?"
echo ""
echo -e "\tloading kacman..."

# Set conda install dir
condaInstallDir="${HOME}/miniconda"

if [[ -z "${1}" ]]
then
    printf "\n\tYou have been eating a blue pill..."
    printf "\tThe ghosts caught you :skull:"
    printf "\tPlease show me the route to the ghosts"
    printf "\tYou want me to chew through\n\t.%s /blue/pills/is/dead/ghosts\n\n" "${0}"
    exit 1
fi

# Change the output directory to suite your needs
read -erp "Enter output directory for test results: " \
    -i "/tmp/pyfunceble4/$(date +'%H%M')" outputDir

# Clean output dir if exist for a clean test environment
if [[ -d "${outputDir}" ]]
then
    rm -fr "${outputDir}"
fi

# Set your desired pyfunceble verion
# We set pyfunceble-dev as default to avoid typos.
read -erp "Which version of PyFunceble would you like to use?: pyfunceble4: " \
    -i "pyfunceble4" pyfunceblePackageName

# Set your test string.
# IMPORTANT: the -f argument is preset as last argument

# Bug #3 test string
read -erp "Enter any custom test string: " \
    -i "--share-logs -dbr 6 -ex --dns 192.168.1.104:53 -w $(nproc --ignore=2) -a --database-type mariadb --no-files --wildcard" -a pyfuncebleArgs

# We should change the default ENV dir to match the PyF versions conda dir
# shellcheck disable=SC2034  # Unused variables left for readability

while true
do
read -erp "Would you like to use your default pyfunceble enviroment
  ${condaInstallDir}/envs/${pyfunceblePackageName}?: [Y/n] " -i "Y" pyfuncebleENV

case $pyfuncebleENV in
    [yY][eE][sS]|[yY])
 useEnvPath="yes"
 break
 ;;
    [nN][oO]|[nN])
 useEnvPath=""
 break
    ;;
    *)
 echo "Invalid input..."
 ;;
 esac
done

# Get the conda CLI.
source "${condaInstallDir}/etc/profile.d/conda.sh"

hash conda

# First Update Conda
conda update -q conda

# Activate your environment
# According to the https://docs.conda.io/projects/conda/en/latest/_downloads/843d9e0198f2a193a3484886fa28163c/conda-cheatsheet.pdf
# We shall replace source with conda activate vs source
conda activate "${pyfunceblePackageName}"

# Make sure output dir is present
mkdir -p "${outputDir}"

# Upgrade the environment
pip install --upgrade pip -q
pip uninstall -yq PyFunceble-dev #"${pyfunceblePackageName}"
pip install --no-cache-dir --upgrade -q 'git+https://github.com/funilrys/PyFunceble@4.0.0-dev#egg=PyFunceble-dev'

if [ "${pyfunceblePackageName}" == 'pyfunceble' ]
then
	pip install --no-cache-dir --upgrade -q 'git+https://github.com/Ultimate-Hosts-Blacklist/whitelist.git@script'
	pyfunceble --version
	uhb-whitelist --version
	#pip list
else
	pip install --no-cache-dir --upgrade -q 'git+https://github.com/Ultimate-Hosts-Blacklist/whitelist.git@script-dev'
	pyfunceble --version
	uhb-whitelist --version
	#pip list
fi

# print pyfunceble version
pyfunceble --version

# Tell the script to install/update the configuration file automatically.
export PYFUNCEBLE_AUTO_CONFIGURATION=yes

# Currently only availeble in the @dev edition see
# GH:funilrys/PyFunceble#94
export PYFUNCEBLE_OUTPUT_LOCATION="${outputDir}/"

# Export ENV variables from $HOME/.config/.pyfunceble-env

if [ -n "$useEnvPath" ]
then
    if [ -f "${condaInstallDir}/envs/${pyfunceblePackageName}/.pyfunceble-env" ]
    then
        rm "${condaInstallDir}/envs/${pyfunceblePackageName}/.pyfunceble-env"
    fi

    if [ ! -f "${condaInstallDir}/envs/${pyfunceblePackageName}/.pyfunceble-env" ]
    then
        cp "$HOME/.config/PyFunceble/.pyfunceble-env.4" "${condaInstallDir}/envs/${pyfunceblePackageName}/.pyfunceble-env"
    fi
    export PYFUNCEBLE_CONFIG_DIR="${condaInstallDir}/envs/${pyfunceblePackageName}/"
else
    export PYFUNCEBLE_CONFIG_DIR="${outputDir}/"
fi

# Run PyFunceble
# Switched to use array to keep quotes for SC2086
pyfunceble "${pyfuncebleArgs[@]}" -f "${1}"

# Output the test variables at the end of the test, as it could have been
# Running for hours and terminal history could be to long to be visible

echo ""
echo ""
echo -e "\tThank you for feting me with all that junk food, I used to like you too..."
echo -e "\tYou tested with: " $(pyfunceble --version)
echo -e "\tYou tested this source: ${1}"
echo -e "\tWith the following variable: ${pyfuncebleArgs[@]}"
echo -e "\tYou're output location is: ${outputDir}"
echo -e "\tThe following files have been generated in the outputDir\n"
echo ""
echo ""

tree --prune -f "${outputDir}"

# When finished - Deactivate the environment
conda deactivate

echo ${?}
