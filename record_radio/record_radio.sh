#!/bin/bash
#
#  bash /storage/emulated/0/github/prod/record_radio.sh
#
#########  crontab  ##############################
#
#  Run every 30 minutes
#  */30 * * * * bash /storage/emulated/0/github/prod/record_radio/record_radio.sh > /storage/emulated/0/github/prod/record_radio/record_radio.log 2>&1
#
#  Run every 1 hour
#  0 * * * * bash /storage/emulated/0/github/prod/record_radio/record_radio.sh > /storage/emulated/0/github/prod/record_radio/record_radio.log 2>&1
#
#########  Config  ###############################

catalog_radio="/storage/emulated/0/Music/Radio";
hours_from=20;
hours_to=7;

#########  Config job  ###########################

echo "~~~~ Start - Config ~~~~";
if [[ -e $catalog_radio ]]; then
    echo "Folder exist $catalog_radio";
else
    echo "Folder not exist $catalog_radio";
    mkdir "$catalog_radio";
    echo "Create dir $catalog_radio";
fi
echo "hours_from=$hours_from"
echo "hours_to=$hours_to"
echo "~~~~ End --- Config ~~~~";
echo "";

#########  Kill active process  ##################

echo "~~~~ Start - Kill active process ~~~~";
name=$( busybox ps | grep curl | grep -v grep | busybox awk '{print $8}' | head -n1 );
echo "Do not kill: name = \"$name\"";

if [[ $name == [a-zA-Z0-9]* ]]; then
    size=$( du -m "$catalog_radio/$name" | busybox awk '{print $1}' );
    echo "Do not kill: size = $size Mb";
    if [[ $size -gt 50 ]]; then
        proc_num=$( pgrep curl | xargs );
        echo "Do kill: proc_num = $proc_num";
        kill "$proc_num";
    else
        echo "Do not killed any processes";
    fi
fi
echo "~~~~ End --- Kill active process ~~~~";
echo "";

#########  Delete old files  #####################

echo "~~~~ Start - Delete old files ~~~~";
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
        file_name="$catalog_radio/$date_radio*";
        echo "DELETE - $file_name";
        rm -r $file_name;
    fi
done
echo "~~~~ End --- Delete old files ~~~~";
echo "";

#########  Record new files  #####################

echo "~~~~ Start - Record new files ~~~~";
hour=$( date +%H | sed s/^0*//g );
file_status=${0//sh/status};
radio_status=$( cat "$file_status" );
echo "Radio status = $radio_status";

if [[ "$radio_status" =~ "RUN" ]]; then
    if [[ $hour -gt $hours_from || $hour -lt $hours_to ]]; then
        echo "Radio recording......";
        cd $catalog_radio || exit;
        curl -o "$(date +%Y-%m-%d__%H-%M-%S)__LuxRadio.mp3" "https://lux.radio.tvstitch.com/kyiv/lux_adv_sd?npa=1" 2> /dev/null &
    else
        echo "Radio no recording......(if $hour -gt $hours_from or $hour -lt $hours_to)";
    fi
else
    echo "Radio no recording......";
fi
echo "~~~~ End --- Record new files ~~~~";
echo "";

#########  Status records  #######################

echo "~~~~ Start - Status records now ~~~~";
busybox ps | grep curl | grep -v grep | busybox awk '{print "pid="$1" - name="$8}';
echo "~~~~ End --- Status records now ~~~~";
echo "";

echo "~~~~ Start - Saved files ~~~~";
ls -lh $catalog_radio;
echo "~~~~ End --- Saved files ~~~~";
echo "";

exit 0;
