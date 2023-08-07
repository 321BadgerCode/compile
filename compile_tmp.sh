#!/bin/bash

#####
#[._.]: ./etc/load_bar.sh(source file):
#####

#badger
load(){
	local text=${1:-"loading..."}
	local percent=${2:-100}
	local wait_time=${3:-.01}
	local is_percent_max=${4:-true}
	local char=${5:-'.'}
	local border=${6:-'|'}
	local border2=${7:-'|'}

	local b1=80 b2=0 b3=0;shift

	for (( a=1; a<=$percent; a++ ));do
		b2="$a"

		if [ "$is_percent_max" = false ];then b3=100
		else b3=$percent
		fi

		printf -v dot "%*s" "$(( $b1*$b2/$b3 ))" "";dot=${dot// /$char}
		printf "\r\e[K${border}%-*s${border2} %3d%% %s" "$b1" "$dot" "$b2" "$text"

		sleep $wait_time
	done;echo
}

#####
#[._.]: ./etc/key_word.sh(source file):
#####

#badger
a1=$1
a2=$@

set_key_word(){
	local key_word="$1"
	local func=$2

	if [ "$a1" == "$key_word" ];then $func && exit
	fi
}

is_key_word(){
	local key_word="$1"

	[[ "$a2" =~ "$key_word" ]]
}

get_key_word_input(){
	local key_word="$1"

	local b1=''
	local b2=''

	if [[ "$a2" =~ "$key_word " ]];then
		b1="${a2##*${key_word} }"
		b2="${b1% *}"
	fi

	echo "$b2"
}

#####
#[._.]: ./etc/info.sh(source file):
#####

#badger
get_current_path(){
	echo "$PWD"
}

get_prev_path(){
	echo "$OLDPWD"
}

get_current_file_name(){
	echo "${0##*/}"
}

#####
#[._.]: ./etc/file.sh(source file):
#####

#badger
set_file_text(){
	local file=$1
	local text=${2:-''}

	echo -n -e $text > $file
}

#set_file_text2(){
#	local file=$1
#	local text=${2:-''}
#
#	cat > $file <<EOF
#	{
#		"contact": {
#			"name": "xyz",
#			"phone_num": "xxx-xxx-xxxx"
#		}
#	}
#EOF
#}

#get_file_text(){
#	local file=$1
#
#	echo -e $(cat $file)
#}

add_file_text(){
	local file=$1
	local text=${2:-''}

	echo -n -e $text >> $file
}

is_file_exist(){
	local file=$1

	[ -f $file ] && [ -e $file ]
}

set_file_permission(){
	local file=$1

	chmod u+x $file
}

delete_file(){
	local file=$1

	rm $file
}

new_file_if_not_exist(){
	local file=$1
	local text=${2:-''}

	test -e $file || echo -n -e $text > $file
}

add_file_to_file(){
	local file=$1
	local file2=$2
	
	cat $file >> $file2
}

get_file_line_num(){
	local file=$1

	local b1=()

	mapfile -t b1 < $file

	echo "$((${#b1[@]}-1))"
}

get_file_line(){
	local file=$1
	local var=$2

	mapfile -t $var < $file
}

get_file_line2(){
	local file=$1
	local index=$2

	local b1=()

	mapfile -t b1 < $file

	echo "${b1[$index]}"
}

set_file_line(){
	local file="$1"
	local line_num="$2"
	local replace="$3"

	sed -i "$((line_num+1)) c \\${replace}" "$file"
}

is_folder_exist(){
	local folder=$1

	[ -d $folder ]
}

new_folder(){
	local folder=$1

	mkdir -p $folder
}

new_folder_if_not_exist(){
	local folder=$1

	if [ ! -d $folder ];then mkdir -p $folder
	fi
}

get_file_from_dir(){
	local dir=$1

	echo "${dir##*/}"
}

get_file_name_from_file(){
	local file=$1

	echo "${file%.*}"
}

get_file_extension_from_file(){
	local file=$1

	echo "${file##*.}"
}

#####
#[._.]: ./etc/error.sh(source file):
#####

#badger
export exception=101

run_time_error(){
	echo "ERROR: AN ERROR OCCURED IN THE PROGRAM AT RUN-TIME!"
}

set_error(){
	trap $1 ERR
}

##############
##################
##############

set -o pipefail
shopt -s expand_aliases
declare -ig __oo__insideTryCatch=0

# if try-catch is nested, then set +e before so the parent handler doesn't catch us
alias try="[[ \$__oo__insideTryCatch -gt 0 ]] && set +e;
           __oo__insideTryCatch+=1; ( set -e;
           trap \"Exception.Capture \${LINENO}; \" ERR;"
alias catch=" ); Exception.Extract \$? || "

Exception.Capture() {
    local script="${BASH_SOURCE[1]#./}"

    if [[ ! -f /tmp/stored_exception_source ]]; then
        echo "$script" > /tmp/stored_exception_source
    fi
    if [[ ! -f /tmp/stored_exception_line ]]; then
        echo "$1" > /tmp/stored_exception_line
    fi
    return 0
}

Exception.Extract() {
    if [[ $__oo__insideTryCatch -gt 1 ]]
    then
        set -e
    fi

    __oo__insideTryCatch+=-1

    __EXCEPTION_CATCH__=( $(Exception.GetLastException) )

    local retVal=$1
    if [[ $retVal -gt 0 ]]
    then
        # BACKWARDS COMPATIBILE WAY:
        # export __EXCEPTION_SOURCE__="${__EXCEPTION_CATCH__[(${#__EXCEPTION_CATCH__[@]}-1)]}"
        # export __EXCEPTION_LINE__="${__EXCEPTION_CATCH__[(${#__EXCEPTION_CATCH__[@]}-2)]}"
        export __EXCEPTION_SOURCE__="${__EXCEPTION_CATCH__[-1]}"
        export __EXCEPTION_LINE__="${__EXCEPTION_CATCH__[-2]}"
        export __EXCEPTION__="${__EXCEPTION_CATCH__[@]:0:(${#__EXCEPTION_CATCH__[@]} - 2)}"
        return 1 # so that we may continue with a "catch"
    fi
}

Exception.GetLastException() {
    if [[ -f /tmp/stored_exception ]] && [[ -f /tmp/stored_exception_line ]] && [[ -f /tmp/stored_exception_source ]]
    then
        cat /tmp/stored_exception
        cat /tmp/stored_exception_line
        cat /tmp/stored_exception_source
    else
        echo -e " \n${BASH_LINENO[1]}\n${BASH_SOURCE[2]#./}"
    fi

    rm -f /tmp/stored_exception /tmp/stored_exception_line /tmp/stored_exception_source
    return 0
}

#####
#[._.]: ./etc/device.sh(source file):
#####

#badger
get_os_type(){
	echo $(uname)
}

get_os_type2(){
	echo "$OSTYPE"
}

get_user(){
	echo "$USER"
}

get_ip(){
	ifconfig eth0 | grep "inet " | cut -c 14-26

	echo "$?"
}

#####
#[._.]: ./etc/color.sh(source file):
#####

#badger
black="\033[0;30m"
red="\033[0;31m"
orange="\033[0;33m"
yellow="\033[1;33m"
green="\033[1;32m"
blue="\033[1;34m"
indigo="\033[0;35m"
violet="\033[1;35m"
white="\033[1;37m"

black2="30"
red2="31"
green2="32"
yellow2="33"
dark_blue2="34"
purple2="35"
light_blue2="36"
white2="37"

normal='0'
light='1'
dark='2'
italic='3'
underline='4'
blink='5'
highlight='7'
strike_through='9'

begin="\033["
end="\033[0m"

set_color(){
	local text=$1
	local color=${2:-${white}}
	local type=${3:-${normal}}

	echo -e "${begin}${type};${color}m${text}${end}"
}

black3=(0 0 0)
red3=(255 0 0)
orange3=(255 125 0)
yellow3=(255 255 0)
green3=(0 255 0)
blue3=(0 0 255)
indigo3=(50 0 125)
violet3=(255 125 255)
white3=(255 255 255)

set_ansi(){ echo -e "\e[${1}m${*:2}\e[0m"; }
set_bold(){ set_ansi 1 "$@"; }
set_dim(){ set_ansi 2 "$@"; }
set_italic(){ set_ansi 3 "$@"; }
set_underline(){ set_ansi 4 "$@"; }
set_blink(){ set_ansi 5 "$@"; }
set_invisible(){ set_ansi 8 "$@"; }
set_strike_through(){ set_ansi 9 "$@"; }
set_underline2(){ set_ansi 21 "$@"; }
set_overline(){ set_ansi 53 "$@"; }

set_fg_color(){
	local text=$1
	local color=${2:-${white[@]}}

	echo -e "\e[38;2;${color[0]};${color[1]};${color[2]}m${text}\e[0m"
}
set_bg_color(){
	local text=$1
	local color=${2:-${black[@]}}

	echo -e "\e[48;2;${color[0]};${color[1]};${color[2]}m${text}\e[0m"
}

#####
#[O-O]: ./compile(main/input file):
#####

#!/bin/bash
#badger
#. ./etc/color.sh #[._.]: this line has been edited(commented out) by ./compile.
#. ./etc/device.sh #[._.]: this line has been edited(commented out) by ./compile.
#. ./etc/error.sh #[._.]: this line has been edited(commented out) by ./compile.
#. ./etc/file.sh #[._.]: this line has been edited(commented out) by ./compile.
#. ./etc/info.sh #[._.]: this line has been edited(commented out) by ./compile.
#. ./etc/key_word.sh #[._.]: this line has been edited(commented out) by ./compile.
#. ./etc/load_bar.sh #[._.]: this line has been edited(commented out) by ./compile.

help(){
	echo -e "help:\n"
	echo -e "usage: compile '${blue}file dir. 2 be compiled${end}' [-o: out file] [-v||--verbose] [-q question]."
	echo -e "syntax: compile -[h|a|i|n|w|i2] || --[help|about|info|need|welcome|install].\n"
	echo "option:"
	echo -e "${red}o:\tout/compiled(.exe) file${end}"
	echo -e "${orange}v:\tinform user of actions"
	echo -e "${yellow}q:\tquestions at end 4 more options\n"
	echo -e "${red}h:\thelp.${end}"
	echo -e "${orange}a:\tabout.${end}"
	echo -e "${yellow}i:\tinfo.${end}"
	echo -e "${green}n:\tneed these programs installed, so they can be utilized by this program.${end}"
	echo -e "${blue}w:\twelcome.${end}"
	echo -e "${indigo}i2:\tinstall programs needed by this program.${end}"
}
about(){
	echo -e "about:\n"
	echo -e "${red}*${end}'compile' compiles a given bash(.sh) file into a stand-alone executable(binary) using 'shc'(.sh->.c) and 'gcc'(.c->bin.).${end}"
}
info(){
	echo -e "info.:\n"
	echo -e "author: ${blue}Badger Code${end}"
	echo -e "dir.: ${yellow}$(get_current_dir)/$(get_name_current_file)${end}"
}
need(){
	echo -e "need 4 program 2 work on your $(get_os_type)($(get_os_type2)) O.S.:\n"
	echo -e "'compile' needs the following programs installed(dependencies):"
	echo -e "1. ${red}shc${end}"
	echo -e "2. ${orange}gcc${end}"
	echo -e "\ntype '${green}compile -i2${end}' or '${green}compile --install${end}' 2 install the necessary components."
}
welcome(){
	load "computing..." 100 .001 true '#'

	clear

	echo -e "${green}[._.]:${end} ${blue}$(get_user)${end}${green}, welcome to the compiling program!${end}\n"
}
install(){
	try {
		sudo apt-get install gcc
	} catch {
		echo -e "${red}ERROR: [-.-]:${end} ${orange}GCC${end} ${red}HAD TROUBLE INSTALLING!${end}"
		exit 1
	}

	try {
		sudo add-apt-repository ppa:neurobin/ppa
		sudo apt-get update
		sudo apt-get install shc
	} catch {
		echo -e "${red}ERROR: [O_O]:${end} ${orange}SHC${end} ${red}HAD TROUBLE INSTALLING!${end}"
		exit 1
	}
}
compile(){
	local input_file2=$1
	local file22=$2
	local out_file2=$3

	shc -f $file22 -o $out_file2 2>/dev/null

	load "compiling..."

	echo -e "${green}[._.]:${end} ${blue}${input_file2}${end} ${green}is compiled;${end} ${blue}${input_file2}${end}${green}=>${end}${orange}${out_file2}${end}"
}

set_key_word "-h" help
set_key_word "-a" about
set_key_word "-i" info
set_key_word "-n" need
set_key_word "-w" welcome
set_key_word "-i2" install

set_key_word "--help" help
set_key_word "--about" about
set_key_word "--info" info
set_key_word "--need" need
set_key_word "--welcome" welcome
set_key_word "--install" install

set_error "run_time_error"

welcome

input_file=$1
if [ "$input_file" == '' ];then
	echo -e "${yellow}[-_-]:${end} ${red}ERROR; NO INPUT FILE SPECIFIED IN COMMAND LINE ARGS!${end}"
	help && exit
fi
out_file=$(get_key_word_input "-o")

a1=$(get_file_from_dir "$input_file")
file2="$(get_file_name_from_file "$a1")_tmp.sh"

if [ "$out_file" == '' ];then
	out_file="./$(get_file_name_from_file $a1).exe"
fi

if ! is_file_exist $input_file;then
	echo -e "*${red}[._.]:${end} '${yellow}${input_file}${end}' ${red} doesn't exist!${end}"
	echo "*check the file that u specified after running the 'compile' command to make sure that it is set and correct."
	echo "*try running 'compile -h' in your terminal 4 more info on the usage of this program."
	exit
fi

if [ $(get_file_extension_from_file "$input_file") != "sh" ];then
	echo -e "*${red}[._.]:${end} '${yellow}${input_file}${end}' ${red}is not a bash file!${end}"
	echo "*check the file that u specified after running the 'compile' command to make sure that it is set and correct."
	echo "*try running 'compile -h' in your terminal 4 more info on the usage of this program."
	exit
fi

if ! is_file_exist $file2;then set_file_text $file2 "#!/bin/bash\n\n"
else
	echo -e "${red}[._.]:${end} '${yellow}${file2}${end}' ${red}already exists!${end}"
	read -r -p "do you want to over-write it? [y/n] " over_write
	clear

	if [ "$over_write" = 'y' ];then
		set_file_text $file2 "#!/bin/bash\n\n"
	else
		echo -e "${green}[._.]:${end} '${blue}${file2}${end}' ${green}is not over-written!${end}"

		read -n 1 -r -p "compile existing file(y/n)? " compile_exist

		if [ "$compile_exist" = 'y' ];then compile "$input_file" "$file2" "$out_file";fi

		exit
	fi
fi

source_file=("$input_file")

for (( a=0; a<${#source_file[@]}; a++ ));do
	get_file_line "${source_file[$a]}" source_line

	for (( b=0; b<${#source_line[@]}; b++ ));do
		if [[ "${source_line[$b]}" =~ ^\.\s* ]];then
			source_file+=($(echo "${source_line[$b]}" | sed "s/^\.\s*//"))
		#elif [[ $line =~ ^source\s* ]];then
			#source_file+=($(echo $line | sed "s/^\source\s*//"))
		fi
	done
done

echo -e "[._.]: ${blue}${input_file}${end} is being compiled 2 ${green}${out_file}${end}...\n"
echo "[._.]: the following files will be included in the compiled file:"
for (( a=0; a<${#source_file[@]}; a++ ));do
	echo -n -e "$(set_color "$((a+1))" "${red2}" "${light}").\t"

	if [ $a == 0 ];then echo "$(set_blink $(set_overline $(set_underline $(set_italic "${green}${source_file[$a]}${end}"))))"
	else echo -e "${green}${source_file[$a]}${end}";fi
done

for (( a=$((${#source_file[@]}-1)); a>=1; a-- ));do
	file="${source_file[$a]}"

	if ! is_file_exist $file;then
		echo -e "*${red}[._.]:${end} '${yellow}${file}${end}' ${red}doesn't exist!${end}"
		echo "*check the file that u specified in your script and make sure that it is correct."
		echo -e "*a possible issue could be that this program cannot access the source file because u used \"./\" 4 the source file in your script and this program is not located in the local dir.."
		echo "*try running 'compile -h' in your terminal 4 more info. on the usage of this program."
		exit
	elif [ $(get_file_extension_from_file "$file") != "sh" ];then
		echo -e "*${red}[._.]:${end} '${yellow}${file}${end}' ${red}is not a bash file!${end}"
		echo "*check the file that u specified in your script and make sure that it is correct."
		echo "*try running 'compile -h' in your terminal 4 more info. on the usage of this program."
		exit
	fi

	add_file_text $file2 "#####\n#[._.]: ${file}(source file):\n#####\n\n"
	add_file_to_file $file $file2
	add_file_text $file2 "\n\n"
done

add_file_text $file2 "#####\n#[O-O]: ${input_file}(main/input file):\n#####\n\n"
add_file_to_file $input_file $file2

all_line=();get_file_line $file2 all_line

for (( a=0; a<${#all_line[@]}; a++ ));do
	if [[ ${all_line[$a]} =~ ^\.\s* ]];then
		set_file_line $file2 $a "#${all_line[$a]} #[._.]: this line has been edited(commented out) by ./compile."
		
		if is_key_word "-v" || is_key_word "--verbose";then
			echo -e "\n${blue}${file2}${end}(line ${red}$((a+1))${end}):"
			echo -e "\"${yellow}${all_line[$a]}${end}\""
			echo -e "\t${yellow}-${end}${orange}>${end}"
			echo -e "\"${orange}$(get_file_line2 $file2 $a)${end}\""
		fi
	fi
done

if is_key_word "-q";then
	read -n 1 -r -p "change text in file that contain old file name(y/n)? " change_name
	echo

	if [ "$change_name" = "y" ];then
		sed -i "s|${input_file}|${out_file}|g" "$file2"
	fi

	read -n 1 -r -p "change text in file, so \"source\"->'.'(y/n)? " change_source
	echo

	if [ "$change_source" = "y" ];then
		sed -i "s/source /. /g" "$file2"
	fi
fi

compile "$input_file" "$file2" "$out_file"

read -n 1 -r -p "delete temporary(tmp) file(${file2}) && .c file(${file2}.x.c)(y/n)? " delete_tmp
echo

if [ "$delete_tmp" = "y" ];then
	delete_file $file2
	delete_file $file2.x.c
fi

if is_key_word "-q";then
	read -n 1 -r -p "run compiled file(y/n)? " run_file
	echo

	if [ "$run_file" = "y" ];then
		./$out_file
	fi
fi
#make more stuff->func.
#get_file_line $file2: make so don't need var. input 2 set
#FIXME: outputted files not sent to path of inputted file, sent to path where `compile.sh` is.
