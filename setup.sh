#! /bin/bash

function custom_echo()
{
  text=$1
  color=$2

  case $color in
    "green")
      echo -e "\033[32m[MJLEE111] $text\033[0m"
      ;;
    "red")
      echo -e "\033[31m[MJLEE111] $text\033[0m"
      ;;
    *)
      echo "$text"
      ;;
  esac
}

custom_echo "ros2_create_qt_pkg setup running ! " "green"
custom_echo "Moving scrips to ~/" "green"
cd ..
mv ros2_create_qt_pkg ~/.ros2_create_qt_pkg_scripts

echo 'ros2_create_qt_pkg() {
    local package_name="$1"
    shift 
    local dependencies="$@"
    local current_directory="$PWD"
    /home/"$USER"/.ros2_create_qt_pkg_scripts/ros2_create_qt_pkg.sh "$current_directory" "$package_name" "$dependencies"
}' >> ~/.bashrc
source ~/.bashrc

sudo apt-get -y install tree