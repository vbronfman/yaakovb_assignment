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

merge()
{  
#     Merge multiple files
echo Running merge of ${files[*]} ...
# # merge two files
  yq -n "load(\"${files[0]}\") * load(\"${files[1]}\")"

# # merge using globs:
# # note the use of `ea` to evaluate all the files at once
# # instead of in sequence
# yq ea '. as $item ireduce ({}; . * $item )' path/to/*.yml


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

# Get input args
get_args $@
echo Args: $oper ${files[@]}

eval $oper
