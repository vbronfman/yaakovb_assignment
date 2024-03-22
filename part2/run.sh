#!/bin/bash
# Argument = -t test -r server -p password -v

declare -a files

Help()
{
# Display Help
echo "Provide at least one argument"
echo "Script options:"
echo
echo "Syntax: ./run.sh <option> <file1> <file2>"
echo "options:"
echo " merge Merge the files"
echo " unique Extract the Unique keys along with their values"
echo " common Extract the Common (key, value) pairs"
echo " sort Sort the files by key"
echo
}

get_args()
{
    # exact 3 args ,
# cat << EOF
# usage: $0 options
#    -v      Verbose
# EOF

# ARG_LIST=("merge" "uniq" "common" "sort")
# # read arguments with opts utility / part of  util-linux package
# opts=$(getopt -a --longoptions "$(printf "%s:," "${ARG_LIST[@]}")" \
#   --name "$(basename "$0")" \
#   -options "" \
#   -- "$@"
# )

#eval set --$opts
# Script expects exact 3 parametres - not more and not the less
[[ $# -eq 3 ]] || eval "Help;exit 11" 

  case "$1" in
    merge|unique|common|sort)
      oper=$1
# Gets file and verifies uniqness (at least by name, pure showing off). 
# The test is sort redundunt as long as task declares that 
# script has to tackle 'any' files
#  add files to array 'files'
      shift
      while [[ $# -gt 0 ]];do
        [[ ${#files[@]} -gt 0 && $1 =~ ${files[@]} ]] && printf "Blah %s\n" ${files[*]} 
        [[ -e $1 ]] && files+=($1) || eval "Help;exit 113"
        shift
      done

      ;;
    *)
      Help
      exit 0;
      ;;
  esac
#done
}


merge()
{  
#  Merge multiple files
echo Running merge of ${files[*]} ...
# merge two files $2 into $1
#  yq -n "load(\"${files[0]}\") * load(\"${files[1]}\")"

 yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' $1 $2

}


unique()
{
# Extract the Unique keys along with their values
     # yq eval-all '... comments="" | with_entries(select(fileIndex == 0))' "$1" "$2" -M  # doesn't work
    #  yq -P 'sort_keys(..)' -o=props first.yaml 
    # yq -P '... comments=""' -o=props first.yaml  and remove comments
# name = John Doe
# age = 30
# city = New York
# contacts.0.name = Jane Smith
# contacts.0.phone = 555-1234
# contacts.1.name = Bob Johnson
# contacts.1.phone = 555-5678
# details.hobbies.0 = Reading
# details.hobbies.1 = Hiking
# details.height = 175 cm
# details.weight = 70 kg
# unique_key_data1 = Unique data in file 1

    declare -A arr1=(); IFS=' = '; while read -r a b; do arr1["$a"]="$b"; done < <( yq   -P 'sort_keys(...) comments="" ' -o=p $1 )
    declare -A arr2=(); IFS=' = '; while read -r a b; do arr2["$a"]="$b"; done < <( yq   -P 'sort_keys(...) comments="" ' -o=p $2 )
 # as dull as it   
    for x in "${!arr1[@]}"; do # !indices 
      [[  -z ${arr2[$x]+x} ]] && printf "$1 Unique key:  %s = %s \n" $x  ${arr1[$x]}
    done
# should be a better way
    for x in "${!arr2[@]}"; do # !indices 
      [[  -z ${arr1[$x]+x} ]] && printf "$2 Unique key:  %s = %s \n" $x  ${arr2[$x]}
    done    
} 

common()
{  
# Extract the Common (key, value) pairs
    # damn you, chatgpt # yq eval-all '. as $item | keys[] | select($item[.] == inputs | has($item[.])) | [., $item[.] ]' "$1" "$2"
    # darn you, chatgpt # yq eval '... comments="" | with_entries(select(fileIndex == 0) | select(.value == (.. | select(fileIndex == 1))))' "$1" "$2" -M
    declare -A arr1=(); IFS=' = '; while read -r a b; do arr1["$a"]="$b"; done < <( yq   -P 'sort_keys(...) comments="" ' -o=p $1 )
    declare -A arr2=(); IFS=' = '; while read -r a b; do arr2["$a"]="$b"; done < <( yq   -P 'sort_keys(...) comments="" ' -o=p $2 )
    
    for x in "${!arr1[@]}"; do # !indices 
      [[  ${arr1[$x]} == ${arr2[$x]} ]] && printf "Common key:  %s = %s \n" $x  ${arr2[$x]}
    done   
} 

sort()
{
# Sort the files by key
    # yq eval-all 'select(fileIndex == 0) | to_entries | sort_by(.key) | from_entries' "$1" "$2"
    # https://github.com/mikefarah/yq/issues/1024#issuecomment-985956548
    #yq eval '... comments="" | sort_by(.key)' "$1" "$2" -M  # this is 
    #yq -i -P 'sort_keys(..)' f1.yaml # https://mikefarah.gitbook.io/yq/operators/sort-keys
    # https://mikefarah.gitbook.io/yq/operators/entries#custom-sort-map-keys 
    for i in $@ ;do
        yq --inplace '. comments="" | to_entries | sort_by(.key)  | from_entries' $i  # it works!   
    done
} 

##### MAIN #####

# Turns out there is quite a discrepancy in behavior of the utility starting version 4.xx
# Check if yq version is 4.xx
yq_version=$(yq --version | grep -oP '(?<=version v)\d') # yq (https://github.com/mikefarah/yq/) version v4.40.2
if [[ "$yq_version" -lt 4 ]]; then
    echo "This script requires yq version 4.xx or above."
    exit 1
fi

# Get input args
get_args $@
echo Args: $oper ${files[@]}

eval "$oper ${files[@]}"
