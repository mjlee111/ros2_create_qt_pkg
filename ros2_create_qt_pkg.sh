#! /bin/bash

function custom_echo() {
  text=$1
  color=$2

  case $color in
    "green")
      echo -e "\033[32m[MJLEE111] $text\033[0m"
      ;;
    "red")
      echo -e "\033[31m[MJLEE111] $text\033[0m"
      ;;
    "orange")
      echo -e "\033[33m[MJLEE111] $text\033[0m"
      ;;
    *)
      echo "$text"
      ;;
  esac
}

loading_animation() {
  local interval=1
  local duration=10
  local bar_length=$(tput cols)  
  local total_frames=$((duration * interval))
  local frame_chars=("█" "▉" "▊" "▋" "▌" "▍" "▎" "▏")

  for ((i = 0; i <= total_frames; i++)); do
    local frame_index=$((i % ${#frame_chars[@]}))
    local progress=$((i * bar_length / total_frames))
    local bar=""
    for ((j = 0; j < bar_length; j++)); do
      if ((j <= progress)); then
        bar+="${frame_chars[frame_index]}"
      else
        bar+=" "
      fi
    done
    printf "\r\033[32m%s\033[0m" "$bar"  
    sleep 0.$interval
  done

  printf "\n"
}

replace_text_in_file() {
    local file_path="$1"
    local search_text="$2"
    local replace_text="$3"

    if [ ! -f "$file_path" ]; then
        return 1
    fi
    sed -i "s/$search_text/$replace_text/g" "$file_path"
}

change_pkgxml(){
  local file_path="$1"
  local search_text="$2"
  local depends="$3"

  if [ ! -f "$file_path" ]; then
        return 1
  fi 

  IFS=' ' read -ra dependencies <<< "$depends"
    
  local result=""
    
  for dependency in "${dependencies[@]}"; do
      result+="<build_depend>$dependency</build_depend>\n"
      result+="<run_depend>$dependency</run_depend>\n"
  done
  sed -i "s/$search_text/$replace_text/g" "$file_path"

}

custom_echo "ros2_create_qt_pkg ROS GUI package [github.com/mjlee111]" "orange"
cur_path="$1"
package_name="$2"
depends="$3"
script_path="/home/$USER/.ros2_create_qt_pkg_scripts/qt-ros/"

if [[ $package_name =~ [A-Z] || $package_name =~ [^a-zA-Z0-9_] ]]; then
    custom_echo "ROS package name must not contain Uppercase or Special Characters!" "red"
    exit 1
fi

if [ -d "$script_path" ]; then
    loading_animation
else
    custom_echo "ros2_create_qt_pkg not installed correctly!!" "red"
    custom_echo "Please re-install it from github.com/mjlee111/ros2_create_qt_pkg" "red"
    exit 1
fi
custom_echo "Creating ROS GUI package. Package name : $package_name" "green"
custom_echo "Dependencies : $depends" "green"

new_depends=""
IFS=' ' read -ra dependencies <<< "$depends"
for dependency in "${dependencies[@]}"; do
    if [ "$dependency" != "rclcpp" ]; then
        new_depends+=" $dependency"
    fi
done

depends="${new_depends# }"

if [ -z "$package_name" ]; then
  custom_echo "You Should Enter a package name!" "red"
  custom_echo "ros2_create_qt_pkg [package_name] [dependencies]" "red"
  exit 1
fi

cd $cur_path
mkdir $package_name
cd $package_name

mkdir src
mkdir -p include/$package_name 

cp $script_path/CMakeLists.txt .
cp $script_path/package.xml .
replace_text_in_file "CMakeLists.txt" "%(dependencies)s" "$depends"
replace_text_in_file "CMakeLists.txt" "%(package)s" "$package_name"
change_pkgxml "package.xml" "%(depends)s" "$depends"
replace_text_in_file "package.xml" "%(package)s" "$package_name"


cd src
cp $script_path/src/main_window.cpp .
cp $script_path/src/qnode.cpp .
cp $script_path/src/main.cpp .
replace_text_in_file "main_window.cpp" "% (package)s" "$package_name"
replace_text_in_file "qnode.cpp" "% (package)s" "$package_name"
replace_text_in_file "main.cpp" "% (package)s" "$package_name"

cd $cur_path/$package_name/include/$package_name
cp $script_path/include/PACKAGE_NAME/main_window.hpp .
cp $script_path/include/PACKAGE_NAME/qnode.hpp .
replace_text_in_file "main_window.hpp" "% (package)s" "$package_name"
replace_text_in_file "qnode.hpp" "% (package)s" "$package_name"

cd $cur_path/$package_name
cp -R $script_path/ui . 
cp -R $script_path/resources . 

custom_echo "Created ROS GUI package ! Might need to change package.xml file :)" "green"
custom_echo "Package Overview" "green"
cd $cur_path/$package_name
tree



