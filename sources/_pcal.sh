#!/usr/bin/env bash

BREAKS=(-61 9 38 199 426 686 756 818 1111 1181 1210 1635 2060 2097 2192 2262 2324 2394 2456 3178)
DAY_NAMES_FA=(Sh Ye Do Se Ch Pa Jo)
declare -A DAY_NAMES=([Sh]=0 [Ye]=1 [Do]=2 [Se]=3 [Ch]=4 [Pa]=5 [Jo]=6)
declare -A DAY_NAMES_EN=([Sat]=Sh [Sun]=Ye [Mon]=Do [Tue]=Se [Wed]=Ch [Thu]=Pa [Fri]=Jo)
MONTH_NAMES=(Farvardin Ordibehesht Khordad Tir Mordad Shahrivar Mehr Aban Azar Dey Bahman Esfand)

exit_error() {
    echo >&2 "$1"
    exit 1
}

to_jalaali() {
    local gy=$1
    local gm=$2
    local gd=$3

    echo $(d2j $(g2d $gy $gm $gd))
}

to_gregorian() {
    local jy=$1
    local jm=$2
    local jd=$3

    echo $(format_output $(d2g $(j2d $jy $jm $jd)))
}

g2d() {
    local gy=$1
    local gm=$2
    local gd=$3
    local d=$(((gy + (gm - 8) / 6 + 100100) * 1461 / 4 + (153 * ((gm + 9) % 12) + 2) / 5 + gd - 34840408))

    echo $((d - ((gy + 100100 + (gm - 8) / 6) / 100) * 3 / 4 + 752))
}

d2g() {
    local jdn=$1
    local j=$((4 * jdn + 139361631))
    j=$((j + (3 * ((4 * jdn + 183187720) / 146097) / 4) * 4 - 3908))
    local i=$((((j % 1461) / 4) * 5 + 308))
    local gd=$((((i % 153) / 5) + 1))
    local gm=$(((i / 153) % 12 + 1))
    local gy=$((j / 1461 - 100100 + (8 - gm) / 6))

    echo "$gy $gm $gd"
}

jal_cal() {
    local jy=$1
    local without_leap=$2
    local bl=${#BREAKS[@]}
    local gy=$((jy + 621))
    local leapj=-14
    local jp=${BREAKS[0]}

    if [[ $jy -lt $jp || $jy -ge ${BREAKS[$((bl - 1))]} ]]; then
        exit_error "Invalid Jalaali year $jy"
    fi

    for ((i = 1; i < bl; i++)); do
        local jm=${BREAKS[$i]}
        local jump=$((jm - jp))

        if [[ $jy -lt $jm ]]; then
            break
        fi

        leapj=$((leapj + (jump / 33) * 8 + (jump % 33) / 4))
        jp=$jm
    done

    local n=$((jy - jp))
    leapj=$((leapj + (n / 33) * 8 + ((n % 33) + 3) / 4))

    if [[ $((jump % 33)) -eq 4 && $((jump - n)) -eq 4 ]]; then
        leapj=$((leapj + 1))
    fi

    leapg=$((gy / 4 - ((gy / 100) + 1) * 3 / 4 - 150))
    march=$((20 + leapj - leapg))

    if [[ $without_leap == "false" ]]; then
        if [[ $((jump - n)) -lt 6 ]]; then
            n=$((n - jump + ((jump + 4) / 33) * 33))
        fi

        local leap=$((((n + 1) % 33 - 1) % 4))

        if [[ leap -eq -1 ]]; then
            leap=4
        fi
    fi

    echo "$leap $gy $march"
}

d2j() {
    local jdn=$1
    local gy=$(d2g $jdn)
    gy=${gy%% *}
    local jy=$((gy - 621))
    local r="$(jal_cal $jy 'false')"
    local jdn1f=$(g2d $gy 3 ${r##* })
    local k=$((jdn - jdn1f))

    if [[ $k -ge 0 ]]; then
        if [[ $k -le 185 ]]; then
            local jm=$((1 + k / 31))
            local jd=$((k % 31 + 1))

            echo "$(format_output $jy $jm $jd)"
            return 0
        else
            k=$((k - 186))
        fi
    else
        jy=$((jy - 1))
        k=$((k + 179))

        if [[ ${r%% *} -eq 1 ]]; then
            k=$((k + 1))
        fi
    fi

    local jm=$((7 + k / 30))
    local jd=$((k % 30 + 1))

    echo "$(format_output $jy $jm $jd)"
}

j2d() {
    local jy=$1
    local jm=$2
    local jd=$3
    local r=$(jal_cal $jy "true")
    local gy=${r#* }
    gy=${gy% *}
    local g2d_res=$(g2d $gy 3 ${r##* })

    echo $((g2d_res + (jm - 1) * 31 - (jm / 7) * (jm - 7) + jd - 1))

}

zero_pad() {
    local num=$1

    [[ $num -lt 10 ]] && num="0$num"

    echo "$num"
}

format_output() {
    local jy=$1
    local jm=$(zero_pad $2)
    local jd=$(zero_pad $3)
    local odel=${OPTION_ODEL--}

    echo "$jy$odel$jm$odel$jd"
}

parse_input() {
    local input_date=$1
    local idel=${OPTION_IDEL:--}
    local y=${input_date%%$idel*}
    local m=${input_date%$idel*}
    m=${m#*$idel}
    local d=${input_date##*$idel}

    echo "$((10#$y)) $((10#$m)) $((10#$d))"
}

is_leap_jalaali_year() {
    [[ $(jal_cal_leap $(current_persian_year)) -eq 0 ]] && echo "true" && return 0
    echo "false"
}

jal_cal_leap() {
    local jy=$1
    local bl=${#BREAKS[@]}
    local jp=${BREAKS[0]}

    if [[ $jy -lt $jp || $jy -ge ${BREAKS[$((bl - 1))]} ]]; then
        echo "Invalid Jalali year $jy"
        exit 0
    fi

    for ((i = 1; i < bl; i++)); do
        local jm=${BREAKS[$i]}
        local jump=$((jm - jp))
        [[ $jy -lt $jm ]] && break
        jp=$jm
    done

    local n=$((jy - jp))
    [[ $((jump - n)) -lt 6 ]] && n=$((n - jump + ((jump + 4) / 33) * 33))
    local leap=$((((n + 1) % 33 - 1) % 4))
    [[ $leap -eq -1 ]] && leap=4
    set -x
    echo $leap
}

jalaali_month_length() {
    local jm=$1

    [[ $jm -le 6 ]] && echo "31" && return 0
    [[ $jm -le 11 ]] && echo "30" && return 0
    [[ $(is_leap_jalaali_year) == "true" ]] && echo "30" && return 0
    echo "29"
}

print_current_month() {
    local index=$(first_day_of_month)
    local counter=0
    local day=1
    local current_month=$(current_persian_month)
    local month_length=$(jalaali_month_length $current_month)
    local fcolor='\e[39m'
    local bcolor='\e[49m'
    local dfcolor='\e[39m'
    local dbcolor='\e[49m'
    local current_day=$(current_persian_day)
    local current_month_name=${MONTH_NAMES[$((current_month - 1))]}
    local month_name_length=${#current_month_name}
    local month_pad=$(((21 + month_name_length) / 2))

    printf '%12s\n' $(current_persian_year)
    printf "%${month_pad}s\n" $current_month_name
    echo ${DAY_NAMES_FA[@]}

    for ((i = 0; i < 6; i++)); do
        for ((j = 0; j < 7; j++)); do
            if [[ $counter -lt $index || $day -gt $month_length ]]; then
                printf "   "
            else
                if [[ $j -eq 6 ]]; then
                    fcolor='\e[31m'
                elif [[ $j -eq 5 ]]; then
                    fcolor='\e[95m'
                else
                    fcolor=$dfcolor
                fi

                if [[ $day -eq $current_day ]]; then
                    bcolor='\e[42m'
                else
                    bcolor=$dbcolor
                fi

                printf "$bcolor$fcolor%02d$dfcolor$dbcolor " $day
                day=$((day + 1))
            fi
            counter=$((counter + 1))
        done
        echo ""
    done
    echo ""
}

find_en_day_name() {
    local first_day_number=$1
    local current_seconds=$(printf '%(%s)T' -1)
    local first_date_seconds=$((current_seconds - (first_day_number - 1) * 86400))
    echo "$(printf '%(%a)T' $first_date_seconds)"
}

first_day_of_month() {
    local current=$(current_persian_date)
    local first_day_number=$((10#${current##*-}))

    echo ${DAY_NAMES[${DAY_NAMES_EN[$(find_en_day_name $first_day_number)]}]}
}

current_persian_date() {
    local current_g=$(printf '%(%F)T' -1)
    local current_j=$(to_jalaali $(parse_input $current_g))
    echo "$current_j"
}

current_persian_day() {
    local current=$(current_persian_date)
    local current_day=${current##*-}
    echo $((10#$current_day))
}

current_persian_month() {
    local current=$(current_persian_date)
    local current_month=${current%-*}
    current_month=${current_month#*-}
    echo $((10#$current_month))
}

current_persian_year() {
    local current=$(current_persian_date)
    local current_year=${current%%-*}
    echo $((10#$current_year))
}

print_help() {
    echo "Usage: pcal [d idelim] [D odelim]"
    echo "  Convert Gregorian calendar date to Persian calendar date."
    echo ""
    echo "  Reads a Gregorian calendar date from standard input and prints "
    echo "  its corresponding Persian calendar date to standard output."
    echo ""
    echo "  Options:"
    echo "    -h          display this help and exit"
    echo "    -d idelim   use IDELIM instead of - for input date delimiter"
    echo "    -D Odelim   use ODELIM instead of - for output date delimiter"
    echo "    -g          convert Persian calendar date to Gregorian calendar date"
    echo "    -m          display current Persian month in calendar"
    echo "    -t          print current Persian date"
}

main() {
    local input_data
    local gregorian
    local must_exit=1

    while getopts ":hd:D:gmt" opt; do
        case ${opt} in
        d)
            OPTION_IDEL=$OPTARG
            ;;
        D)
            OPTION_ODEL=$OPTARG
            ;;
        esac
    done

    OPTIND=1

    while getopts ":hd:D:gmt" opt; do
        case ${opt} in
        h)
            print_help
            exit 0
            ;;
        d)
            OPTION_IDEL=$OPTARG
            ;;
        D)
            OPTION_ODEL=$OPTARG
            ;;
        g)
            gregorian=1
            ;;
        t)
            current_persian_date
            exit
            ;;
        m)
            print_current_month
            exit
            ;;
        \?)
            echo "Invalid Option: -$OPTARG" 1>&2
            exit 1
            ;;
        :)
            echo "Invalid Option: -$OPTARG requires an argument" 1>&2
            exit 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    read input_data

    if [[ $gregorian -eq 1 ]]; then
        to_gregorian $(parse_input $input_data)
    else
        to_jalaali $(parse_input $input_data)
    fi
}

main "$@"
