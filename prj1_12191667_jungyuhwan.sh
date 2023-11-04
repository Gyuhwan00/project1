#! /bin/bash

item_file="$1"
data_file="$2"
user_file="$3"

echo "--------------------------"
echo "User Name: Jun-Gyuhwan"
echo "Student Number: 12191667"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u. item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "--------------------------"

while true; do
    read -p "Enter your choice [ 1-9 ] " choice
    case $choice in
        1)
        echo ""
        read -p "Please enter 'movie id'(1~1682):" var
        echo ""
        awk -F\| -v a=$var '$1 == a {print}' "$item_file"
        echo ""
        ;;
        2)
        echo ""
        read -p "Do you want to get the data of ‘action’ genre movies from 'u.item’?(y/n):" var
        echo ""
        if [ "$var" = "y" ]; then
            awk -F\| '$7 == 1 {print $1, $2}' "$item_file" | head -n 10
            echo ""
        fi
        ;;
        3)
        echo ""
        read -p "Please enter the 'movie id’(1~1682):" var
        echo ""
        awk -v a=$var '$2 == a {sum+=$3; count++} END {printf "average rating of %s: %.5f\n", a, sum/count}' "$data_file"
        echo ""
        ;;
        4)
        echo ""
        read -p "Do you want to delete the ‘IMDb URL’ from ‘u.item’?(y/n):" var
        echo ""
        if [ "$var" = "y" ]; then
            sed -e 's/|http:[^|]*|/||/g' -ne '1, 10p' "$item_file"
        fi
        echo ""
        ;;
        5)
        echo ""
        read -p "Do you want to get the data about users from ‘u.user’?(y/n):" var
        echo ""
        if [ "$var" = "y" ]; then
            sed -e 's/\(.*\)|\(.*\)|\(M\)|\(.*\)|\(.*\)/user \1 is \2 years old male \4/' -e 's/\(.*\)|\(.*\)|\(F\)|\(.*\)|\(.*\)/user \1 is \2 years old female \4/' -ne '1, 10p' "$user_file"
        fi
        echo ""
        ;;
        6)
        echo ""
        read -p "Do you want to Modify the format of ‘release data’ in ‘u.item’?(y/n):" var
        if [ "$var" = "y" ]; then
            sed -n '1673,1682p' "$item_file" | while IFS=\| read id title date etc
            do
                date=$(date -d"$date" +%Y%m%d)
                echo "$id|$title|$date|$etc"
            done
        fi
        ;;
        7)
        echo ""
        read -p "Please enter the ‘user id’(1~943):" var
        echo ""
        movies=$(awk -v a="$var" -F'\t' '$1 == a {print $2}' "$data_file" | sort -n)
        echo $movies | tr ' ' '|'
        echo ""
        for id in $(echo $movies | tr ' ' '\n' | head -10)
        do
            title=$(awk -v a="$id" -F\| '$1 == a {print $2}' "$item_file")
            echo "$id|$title"
        done
        echo ""
        ;;
        8)
        echo ""
        read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n):" var
        echo ""
        if [ "$var" = "y" ]; then
            awk -F\| '$4 == "programmer" && $2 >= 20 && $2 < 30 {id[$1]=1} END{for(i in id)print i}' "$user_file" > p_id.txt
            awk -F"\t" 'BEGIN{while(getline <"p_id.txt"){id[$1]=1}} $1 in id {sum[$2]+=$3; count[$2]++} END{for(i in sum) {print i, sum[i]/count[i]}}' "$data_file"
        fi
        echo ""
        ;;
        9)
        echo ""
        echo "Bye!"
        break
        ;;
    esac
done
exit 0

