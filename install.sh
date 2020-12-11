#!/bin/bash
# install the toolbox

date_stamp=$(date +'%Y%m%d-%H%M%S')
bin_dir=$HOME/bin
backup_dir=${bin_dir}/update.${date_stamp}
home=$(pwd)

log_dir=${home}/log
log=${log_dir}/${date_stamp}-install.log
mkdir -p $log_dir

function lnit {
  tool=$1
  bin_link=$bin_dir/$tool

  if [ -L $bin_link ]; then
    mv $bin_link $backup_dir
  fi

  time_regex="[acfm]time"
  line_end_regex="[dmu]2[dmu]"

  echo -n "  + install $tool: "
  cd $bin_dir

  if [[ $tool =~ $time_regex ]]; then
    ln -s $home/script/fst $tool
  elif [[ $tool =~ $line_end_regex ]]; then
    ln -s $home/script/line_end $tool
  else
    ln -s $home/script/$tool $tool
  fi

  [ -e $tool ] && echo "ok" || echo "not_ok"
  cd $home
}

echo; echo " Toolbox Installation $date_stamp"; echo

# -----------------------------------

echo "+ Perl version check"
perl_ver=$(perl -v | grep -Po 'v[\d\.]+')
minor=$(echo $perl_ver |  cut -d '.' -f 2)
state=''

if (( $minor > 13 )); then
  state='ok'
else
  state='v5.14 or greater required'
fi

echo "  * $perl_ver: $state"

# -----------------------------------
required_modules="DateTime IO::Prompt JSON LWP"

echo "+ Modules requiring installation: "
missing=''

for module in $required_modules; do
  perl -e "use $module" 2>/dev/null
  if [[ $? != 0 ]]; then
    [ -z $missing ] && echo || echo "  * "
    missing="$missing $module"
  fi
done

if [ -z "$missing" ]; then
  echo "  * none"
else
  for module in $missing; do
    echo "  * $module"
  done
  echo
  echo "  use => cpan install MODULE_NAME"
fi

# -----------------------------------

if [ ! -e $bin_dir ]; then
  echo "+ Creating $bin_dir"
  mkdir -p $bin_dir
else
  echo "+ Creating backup location at $backup_dir"
  mkdir -p $backup_dir
fi

# -----------------------------------

declare -A toolbox
while read -ra line; do
 toolbox[${line[0]}]=${line[0]}
done < ./tblist.txt

tools=$(echo "${!toolbox[@]}" | sort)

for key in $tools; do
    lnit $key
done

echo; echo " Toolbox Installation complete $date_stamp"; echo
#SDG
