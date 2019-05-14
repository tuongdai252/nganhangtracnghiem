#!/bin/bash

file_cauhoi="cauhoi.txt"
file_traloi="traloi.txt"

[ -e "$file_cauhoi" ] || touch "$file_cauhoi"
[ -e "$file_traloi" ] || touch "$file_traloi"

add_quest(){
	echo
	echo "=========Them cau hoi========="
	read -p "Nhap cau hoi: " cauhoi

	while [[ -z $cauhoi ]]
	do
		echo "Cau hoi cua ban rong!!!"
		read -p "Nhap cau hoi: " cauhoi
	done

	soluongcauhoi=`cat "$file_cauhoi" | grep "~$cauhoi$" | wc -l`
	if [ $soluongcauhoi -eq 1 ]
	then
		sodong=`cat "$file_cauhoi" | grep "~$cauhoi$" | cut -d'~' -f1`
		echo "Loi!!! Cau hoi bi trung voi cau hoi $sodong."
	fi

	if [ $soluongcauhoi -eq 0 ]
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
	cat "$file_cauhoi"
	read -p "Nhap so cau hoi (1,2,3,...) ma ban muon them cau tra loi: " socauhoi
	ktsocauhoi=`cat "$file_cauhoi" | grep "^$socauhoi~" | wc -l`
	while ! [ $socauhoi -eq $socauhoi ] 2>/dev/null || [[ -z $socauhoi ]] || [ $ktsocauhoi -eq 0 ]
	do
		echo "So khong hop le!!!"
		read -p "Nhap so cau hoi (1,2,3,...) ma ban muon them cau tra loi: " socauhoi
		ktsocauhoi=`cat "$file_cauhoi" | grep "^$socauhoi~" | wc -l`
	done
	
	soluongtraloi=`cat "$file_traloi" | grep "^$socauhoi~" | grep -v "^$socauhoi~true~" | wc -l`
	gioihan=`expr 5 - $soluongtraloi`
	[ $gioihan -gt 5 ] && echo "Cau hoi da co 5 cau tra loi!!!" && return 0

	if [ $ktsocauhoi -eq 1 ]
	then
		read -p "Nhap so luong cau tra loi: " so
		while ! [ $so -eq $so ] 2>/dev/null || [[ -z $so ]] || [ $so -gt $gioihan ]
		do
			echo "So khong hop le"
			[ $so -gt $gioihan ] && echo "Chi cho phep toi da 5 cau tra loi!!! Da co $soluongtraloi cau tra loi"
			read -p "Nhap so luong cau tra loi: " so
		done

		for ((i=1;i<=$so;i++))
		do
			read -p "Nhap cau tra loi ($i): " traloi
			while [[ -z $traloi ]]
			do
				echo "Cau tra loi khong duoc rong!!!"
				read -p "Nhap cau tra loi ($1): " traloi
			done

			traloitrung=`cat "$file_traloi" | grep "^$socauhoi~[A-E]~$traloi$" | wc -l`
			[ $traloitrung -eq 1 ] && echo "Loi!!! Cau tra loi da ton tai"

			if [ $traloitrung -eq 0 ]
			then
				line=`cat "$file_traloi" | grep "^$socauhoi~" | grep -v "^$socauhoi~true~" | wc -l`
				line=`expr $line + 1`
				sotraloi=`echo $line | tr '1-5' 'A-E'`
				echo "$socauhoi~$sotraloi~$traloi" >> "$file_traloi"
				echo "Them cau tra loi thanh cong!!!"
			fi
		done
		
		kttraloidung=`cat "$file_traloi" | grep "^$socauhoi~true~" | wc -l`
		[ $kttraloidung -ne 0 ] && return 0

		soluongtraloi=`cat "$file_traloi" | grep "^$socauhoi~" | wc -l`
		if [ $soluongtraloi -ge 2 ]
		then
			cat "$file_traloi" | grep "^$socauhoi~" | cut -d'~' -f2- > getanswer.txt
			while read line
			do
				vephai=`echo "$line" | cut -d'~'  -f2-`
				vetrai=`echo "$line" | cut -d'~' -f1`
				echo "$vetrai. $vephai"
			done < getanswer.txt
			rm -rf getanswer.txt
			read -p "Nhap cau tra loi dung (A,B,C,D,...): " correct
			upcorrect=`echo $correct | tr -s '[:lower:]' '[:upper:]'`
			kttraloidung=`cat "$file_traloi" | grep "^$socauhoi~$upcorrect~" | wc -l`
			while [ $kttraloidung -eq 0 ]
			do
				echo "Dap an khong hop le!!!"
				read -p "Nhap cau tra loi dung (A,B,C,D,...): " correct
				upcorrect=`echo $correct | tr -s '[:lower:]' '[:upper:]'`
				kttraloidung=`cat "$file_traloi" | grep "^$socauhoi~$upcorrect~" | wc -l`
			done

			if [ $kttraloidung -eq 1 ]
			then
				echo "$socauhoi~true~$upcorrect" >> "$file_traloi"
				echo "Them cau tra loi dung thanh cong!!!"
			fi
		fi
	fi
	sort "$file_traloi" -o "$file_traloi"
	echo "=============================="
}

post_exam(){
	echo
	echo "==========Xuat de thi=========="
	sodong=`cat "$file_cauhoi" | wc -l`
	read -p "Nhap so luong cau hoi muon xuat: " socau
	while ! [ $socau -eq $socau ] 2> /dev/null || [[ -z $socau ]] || [ $socau -lt 0 ] || [ $socau -gt $sodong ]
	do
		[[ -z $socau ]] && echo "So cau khong duoc rong!!!"
		[ $socau -eq $socau 2> /dev/null ] || echo "Khong hop le!!! Yeu cau nhap so"
		[ $socau -lt 0 ] && echo "Khong duoc nhap so am!!! Yeu cau nhap lai"
		[ $socau -gt $sodong ] && echo "Ngan hang de thi chi co $sodong cau hoi!!!"
		read -p "Nhap so luong cau hoi muon xuat: " socau
	done
	rm -rf getquest.txt
	while read cauhoi
	do
		socauhoi=`echo "$cauhoi" | cut -d'~' -f1`
		ktcotraloi=`cat "$file_traloi" | grep "^$socauhoi~[A-E]~" | wc -l`
		[ $ktcotraloi -ne 0 ] && echo "$cauhoi" >> getquest.txt
	done < "$file_cauhoi"
	cat getquest.txt | sort -R | head -"$socau" > dethi.txt
	rm -rf getquest.txt
	echo $socau > bailam.txt
	echo $socau > dapan.txt
	i=1
	while read line <&9
	do
		socauhoi=`echo "$line" | cut -d'~' -f1`
		cauhoi=`echo "$line" | cut -d'~' -f2-`
		echo
		echo "Cau $i: $cauhoi"
		cat "$file_traloi" | grep "^$socauhoi~" | grep -v "^$socauhoi~true~" | cut -d'~' -f2- > getanswer.txt
		while read row
		do
			vephai=`echo "$row" | cut -d'~'  -f2-`
			vetrai=`echo "$row" | cut -d'~' -f1`
			echo "$vetrai. $vephai"
		done < getanswer.txt
		rm -rf getanswer.txt
		echo
		read -p "Lua chon cua ban: " bailam
		upbailam=`echo $bailam | tr -s '[:lower:]' '[:upper:]'`
		ktbailam=`cat "$file_traloi" | grep "^$socauhoi~$upbailam~" | wc -l`
		[[ -z $bailam ]] && ktbailam=0
		while [ $ktbailam -eq 0 ]
		do
			read -p "Lua chon cua ban: " bailam
			upbailam=`echo $bailam | tr -s '[:lower:]' '[:upper:]'`
			ktbailam=`cat "$file_traloi" | grep "^$socauhoi~$upbailam~" | wc -l`
			[[ -z $bailam ]] && ktbailam=0
		done
		echo "$i.$upbailam" >> bailam.txt
		dapan=`cat "$file_traloi" | grep "^$socauhoi~true~" | cut -d'~' -f3-`
		echo "$i.$dapan" >> dapan.txt
		i=`expr $i + 1`
	done 9< dethi.txt
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

