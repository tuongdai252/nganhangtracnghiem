#!/bin/bash

file_cauhoi="cauhoi.txt"
file_traloi="traloi.txt"

[ -e "$file_cauhoi" ] || touch "$file_cauhoi"
[ -e "$file_traloi" ] || touch "$file_traloi"

add_quest(){
	echo
	echo "=========Them cau hoi========="
	read -p "Nhap cau hoi: " cauhoi

	test1=`cat "$file_cauhoi" | grep "~$cauhoi$" | wc -l`
	if [ $test1 -eq 1 ]
	then
		error1=`cat "$file_cauhoi" | grep "~$cauhoi$" | cut -d'~' -f1`
		echo "Loi!!! Cau hoi bi trung voi cau hoi $error1."
	fi

	if [ $test1 -eq 0 ]
	then
		line=`cat "$file_cauhoi" | wc -l`
		line=`expr $line + 1`
		echo "$line~$cauhoi" >> "$file_cauhoi"
		echo "Them cau hoi thanh cong!!!"
	fi
	echo "=============================="
}

add_answer(){
	echo
	echo "=======Them cau tra loi======="
	read -p "Nhap cau hoi ma ban muon them cau tra loi: " cauhoi

	test1=`cat "$file_cauhoi" | grep "~$cauhoi$" | wc -l`
	[ $test1 -eq 0 ] && echo "Loi!!! Cau hoi khong ton tai."

	if [ $test1 -eq 1 ]
	then
		socauhoi=`cat "$file_cauhoi" | grep "~$cauhoi$" | cut -d'~' -f1`
		read -p "Nhap so luong cau tra loi: " so
		while ! [ $so -eq $so ] 2>/dev/null
		do
			echo "So khong hop le"
			read -p "Nhap so luong cau tra loi: " so
		done

		for ((i=1;i<=$so;i++))
		do
			read -p "Nhap cau tra loi ($i): " traloi
			error1=`cat "$file_traloi" | grep "^$socauhoi~[a-j]~$traloi$" | wc -l`
			[ $error1 -eq 1 ] && echo "Loi!!! Cau tra loi da ton tai"

			if [ $error1 -eq 0 ]
			then
				line=`cat "$file_traloi" | grep "^$socauhoi~" | wc -l`
				line=`expr $line + 1`
				sotraloi=`echo $line | tr '1-9' 'a-j'`
				echo "$socauhoi~$sotraloi~$traloi" >> "$file_traloi"
				echo "Them cau tra loi thanh cong!!!"
			fi
		done
		
		test2=`cat "$file_traloi" | grep "^$socauhoi~" | wc -l`
		[ $test2 -eq 1 ] && echo "$socauhoi~true~a" >> "$file_traloi"
		if [ $test2 -ge 2 ]
		then
			cat "$file_traloi" | grep "^$socauhoi~" | cut -d'~' -f2- > getanswer.txt
			while read line
			do
				vephai=`echo "$line" | cut -d'~'  -f2-`
				vetrai=`echo "$line" | cut -d'~' -f1`
				echo "$vetrai. $vephai"
			done < getanswer.txt
			rm -rf getanswer.txt
			read -p "Nhap cau tra loi dung (a,b,c,d,...): " correct
			error2=`cat "$file_traloi" | grep "^$socauhoi~$correct~" | wc -l`
			while [ $error2 -eq 0 ]
			do
				echo "Dap an khong hop le!!!"
				read -p "Nhap cau tra loi dung (a,b,c,d,...): " correct
				error2=`cat "$file_traloi" | grep "^$socauhoi~$correct~" | wc -l`
			done

			if [ $error2 -eq 1 ]
			then
				echo "$socauhoi~true~$correct" >> "$file_traloi"
				echo "Them cau tra loi dung thanh cong!!!"
			fi
		fi
	fi
	sapxep=`cat "$file_traloi" | sort`
	echo "$sapxep" > "$file_traloi"
	echo "=============================="
}

post_exam(){
	echo
	echo "==========Xuat de thi=========="
	sodong=`cat "$file_cauhoi" | wc -l`
	read -p "Nhap so luong cau hoi muon xuat: " socau
	while ! [ $socau -eq $socau ] 2> /dev/null || [ $socau -lt 0 ] || [ $socau -gt $sodong ]
	do
		[ $socau -eq $socau 2> /dev/null ] || echo "Khong hop le!!! Yeu cau nhap so"
		[ $socau -lt 0 ] && echo "Khong duoc nhap so am!!! Yeu cau nhap lai"
		[ $socau -gt $sodong ] && echo "Ngan hang de thi chi co $sodong cau hoi!!!"
		read -p "Nhap so luong cau hoi muon xuat: " socau
	done
	touch getquest.txt
	cat "$file_cauhoi" | sort -R | head -"$socau" > getquest.txt
	echo $socau > bailam.txt
	echo $socau > dapan.txt
	i=1
	while read line <&9
	do
		socauhoi=`echo "$line" | cut -d'~' -f1`
		cauhoi=`echo "$line" | cut -d'~' -f2-`
		echo
		echo "Cau $i: $cauhoi"
		cat "$file_traloi" | grep "^$socauhoi~" | cut -d'~' -f2- | head -n -1 > getanswer.txt
		while read row
		do
			vephai=`echo "$row" | cut -d'~'  -f2-`
			vetrai=`echo "$row" | cut -d'~' -f1`
			echo "$vetrai. $vephai"
		done < getanswer.txt
		rm -rf getanswer.txt
		echo
		read -p "Lua chon cua ban: " bailam
		error1=`cat "$file_traloi" | grep "^$socauhoi~$bailam~" | wc -l`
		while [ $error1 -eq 0 ]
		do
			read -p "Lua chon cua ban: " bailam
			error1=`cat "$file_traloi" | grep "^$socauhoi~$bailam~" | wc -l`
		done
		echo "$i.$bailam" >> bailam.txt
		dapan=`cat "$file_traloi" | grep "^$socauhoi~true~" | cut -d'~' -f3-`
		echo "$i.$dapan" >> dapan.txt
		i=`expr $i + 1`
	done 9< getquest.txt
	rm -rf getquest.txt
	echo "==============================="
}

mark_exam(){
	echo
	echo "===========Cham diem==========="
	echo "Bai lam: "
	cat bailam.txt | tail -n +2
	echo
	echo "Dap an: "
	cat dapan.txt | tail -n +2
	echo
	socau=`cat bailam.txt | head -1`
	socausai=`comm -23 bailam.txt dapan.txt | wc -l`
	socaudung=`expr $socau - $socausai`
	#diem=`expr $socaudung \* 10 / $socau`
	diem=`awk 'BEGIN {printf "%.2f\n", ('$socaudung'*10)/'$socau'}'`
	echo "So cau dung: $socaudung/$socau"
	echo "Diem: $diem"
	echo "==============================="
}

while [ true ]
do
	echo
	echo "==============================="
	echo "| 1. Them cau hoi trac nghiem |"
	echo "| 2. Them cau tra loi         |"
	echo "| 3. Xuat de thi trac nghiem  |"
	echo "| 4. Cham trac nghiem         |"
	echo "| 5. Thoat                    |"
	echo "==============================="
	read -p "Lua chon cua ban: " chon
	case $chon in
		1) add_quest;;
		2) add_answer;;
		3) post_exam;;
		4) mark_exam;;
		5) exit 0;;
		*) echo "Lua chon cua ban khong hop le!!!";;
	esac
done

