#!/bin/bash
#
#  bash /storage/emulated/0/github/prod/record_radio.sh
#
#########  Config  ###########################

catalog_radio="/storage/emulated/0/Music/Radio";

#########  Kill active process  ##################

if [[ -e $catalog_radio ]]; then
    echo "Folder exist $catalog_radio";
else
    echo "Folder not exist $catalog_radio";
    mkdir "$catalog_radio";
    echo "Create dir $catalog_radio";
fi

echo "";
echo "~~~Start - Kill active process~~~";
name=$( busybox ps | grep curl | grep -v grep | busybox awk '{print $8}' | head -n1 );
echo "name = \"$name\"";

if [[ $name == [a-zA-Z0-9]* ]]; then
    size=$( du -m "$catalog_radio/$name" | busybox awk '{print $1}' );
    echo "size = $size";
    if [[ $size -gt 50 ]]; then
        proc_num=$( pgrep curl );
        echo "proc_num = $proc_num";
        kill "$proc_num";
    fi
fi
echo "~~~End --- Kill active process";
echo "";

#########  Delete old files  #####################

echo "~~~Start - Delete old files~~~";
now=$(((( $(date +%Y )-1970)*365)+( $( date +%m )*30)+( $(date +%e )) ));
one_day=$(( "$now"-1 ));

delete_time=$( find $catalog_radio/* -type f | grep -Eo "[0-9]{4}-[0-9]{2}-[0-9]{2}" | uniq );

for date_radio in $delete_time; do
    prob_radio=${date_radio//-/ };
    year_radio=$(( ($( echo "$prob_radio" | busybox awk '{print $1}' ) - 1970)*365 ));
    month_radio=$(( $( echo "$prob_radio" | busybox awk '{print $2}' ) * 30 ));
    day_radio=$(( $( echo "$prob_radio" | busybox awk '{print $3}' | sed 's/^0//' ) ));
    weeks_radio=$(( year_radio+month_radio+day_radio ));

    if [ $weeks_radio -le $one_day ]; then
        file_name="$catalog_radio/$date_radio*"
        echo "DELETE - $file_name"
        rm -r $file_name;
    fi
done
echo "~~~End --- Delete old files~~~";
echo "";

#########  Record new files  ####################

echo "~~~Start - Record new files~~~";
hour=$( date +%H | sed s/^0*//g );
file_status=${0//sh/status};
radio_status=$( cat "$file_status" );
echo "Radio status = $radio_status";

if [[ "$radio_status" =~ "RUN" ]]; then
    if [[ $hour -gt 17 || $hour -lt 7 ]]; then
        echo "Radio recording......";
        cd $catalog_radio || exit;
        curl -o "$(date +%Y-%m-%d__%H-%M-%S)__LuxRadio.mp3" https://lux.radio.tvstitch.com/kyiv/lux_adv_sd?npa=1 2> /dev/null &
    else
        echo "Radio no recording......";
    fi
else
    echo "Radio no recording......";
fi
echo "~~~End --- Record new files";

exit 0;
