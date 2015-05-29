### 	Tomasz Dakowicz	4I3	###
### 	3.7 Grafika ¿ó³wiowa	###
###################################

## U¿ywane rejestry:
## bufor obrazu		-> t0
## zmienne na obliczenia-> [t1, t7]
## adres pow do main	-> t8
## bufor danych wejscia	-> t9 
## wspó³rzêdne ¿ó³wia	-> k0, k1
## flaga rysowania	-> s0 (0 -> nie rysuje)
## k¹t ruchu		-> s1
## adres ci¹gu tymczas.	-> s2
## kolor rysowania	-> s3 (tylko bia³y lub czarny)
## pozycja nowego piksel-> s4
## wczytane przesuniecie-> s5
## flaga poprawnosci	-> s6
## liczba wczyt znakow	-> s7

##########################################

#wyœwietlenie liczby typu int
#Argument: rejestr

.macro print(%int)
	move $a0, %int
	li $v0, 1
	syscall
.end_macro

#wyœwietlenie znaku
#Argument: rejestr

.macro pchar(%str)
	lb $a0, (%str)
	li $v0, 11
	syscall
.end_macro

#wyœwietlanie ci¹gu o danej etykiecie
#Argument: label

.macro	pstring(%label)	
	li $v0, 4
	la $a0, %label
	syscall
.end_macro


.macro pfloat(%int)
	mov.s $f12, %int
	li $v0, 2
	syscall
.end_macro

##########################################	
	.data
#test
test:		.asciiz "test"	
	
#plik wynikowy
wyjscie:	.asciiz "turtle.bmp"

#plik wejsciowy
wejscie:	.asciiz "turtle.txt"

#b³¹d
blad_komendy:	.asciiz "Wystapil blad komendy\nKoniec programu\n"

#miejsce na dane wejsciowe
komendy:	.space 50000

polowa:		.float 0.5
                
#sinus od 0 do 90
sin:		.float 0.0, 0.0175, 0.0349,	0.0523,	0.0698,	0.0872,	0.1045,	0.1219,	0.1392,	0.1564,	0.1736,	0.1908,	0.2079,	0.225,	0.2419,	0.2588,	0.2756	0.2924,	0.309,	0.3256,	0.342,	0.3584,	0.3746,	0.3907,	0.4067,	0.4226,	0.4384,	0.454,	0.4695,	0.4848,	0.5,	0.515,	0.5299,	0.5446,	0.5592,	0.5736,	0.5878,	0.6018,	0.6157,	0.6293,	0.6428,	0.6561,	0.6691,	0.682,	0.6947,	0.7071,	0.7193,	0.7314,	0.7431,	0.7547,	0.766,	0.7771,	0.788,	0.7986,	0.809,	0.8192,	0.829,	0.8387,	0.848,	0.8572,	0.866, 0.8746,	0.8829,	0.891,	0.8988,	0.9063,	0.9135,	0.9205,	0.9272,	0.9336,	0.9397,	0.9455,	0.9511,	0.9563,	0.9613,	0.9659,	0.9703,	0.9744,	0.9781,	0.9816,	0.9848,	0.9877,	0.9903,	0.9925,	0.9945,	0.9962,	0.9976,	0.9986,	0.9994,	0.9998, 1.0   
           
#mozliwe komendy do wywo³ania:
ustaw_komenda:		.asciiz "ustaw"
podnies_komenda:	.asciiz "podnies"
opusc_komenda:		.asciiz "opusc"
naprzod_komenda:	.asciiz "naprzod"
obrot_komenda:		.asciiz "obrot"
kolor_komenda:		.asciiz "kolor"	    

#liczba pikseli obrazu 
liczba_p:	.word	57600 

#dane o pikselach (3 bajty na piksel)
obraz:		.space	57600	# 120 * 160 * 3 bajty (R, G, B) 

sep:		.half 0 
             
#dane pliku bmp
bmp_naglowek:	
#naglówek pliku 
		.byte	'B'	#Dwa bajty zawieraj¹ce znaki 'BM' oznaczaj¹ce, ¿e jest to plik BMP.
		.byte	'M'
		.word	0	#Ca³kowity rozmiar pliku wyra¿ony w bajtach.
		.half	0
		.half	0
		.word	54	#Przesuniêcie (wyra¿one w bajtach) danych obrazu (mapy bitowej) od rekordu BITMAPFILEHEADER
#nag³ówek mapy bitowej
		.word	40	#biSize - rozmiar nag³ówka mapy bitowej 
		.word	160	#szerokoœæ obrazu w pikselach
		.word	120	#wysokoœæ obrazu w pikselach
		.half	0
		.half	24	#liczba bitów na piksel
		.word	0	#brak kompresji
		.word	0	#rozmiar mapy bitowej (0 dla pliku bez kompresji)
		.word	0
		.word	0
		.word	0	#liczba kolorow uzywanych (0 oznacza wszystkie)
		.word	0	#liczba kolorów wymaganych (0 oznacza wszystkie)		
		
	.text
######################## MAIN #######################
main:	
	
	jal otworz_plik_txt
	jal tlo
	jal wczytaj_komendy
	jal zapisz_plik_bmp
	b koniec

#---------- otwiera plik z komendami --------------------------
otworz_plik_txt:	
	la $a0, wejscie #nazwa pliku
	li $a1, 0 
	li $a2, 0
	li $v0, 13
	syscall
	
	move $a0, $v0
	li $v0, 14
	la $a1, komendy
	li $a2, 50000
	syscall
	
	#zamknij plik 
	li $v0, 16 
	syscall
	
	la $t9, komendy	#za³aduj adres pocz¹tku bufora wejscia do t9
	jr $ra		#wróæ do maina
	
#---------- wypelnia wszystkie piksele obrazu bia³ym kolorem	
tlo:	
	la $t4, obraz
	li $t3, 255		#bia³y 
	lw $t5, liczba_p 	#wczytaj liczbe pikseli 
	
	la $t0, obraz		#wczytaj adres bufora danych 
wypelnij:
	beqz $t5, powrot 
	sb $t3, 0($t0)		#zapisz 255 dla kazdej sk³adowej RGB
	addiu $t0, $t0, 1
	addiu $t5, $t5, -1
	b wypelnij

powrot:
	jr $ra
	
#---------- rozró¿nia komendy na wejsciu 
wczytaj_komendy:

	move $t8, $ra	#przesun adres powrotu
	
	wczytaj_petla:
		li $s2, 0 
		li $s5, 0 
		li $s6, 0 
		li $s7, 0
	
		sprawdz_koniec_pliku:
			lb $t1, ($t9)
			move $ra, $t8
			beqz $t1, powrot 	#jesli koniec pliku -> wróæ do maina
		
		# porownaj zgodnosc z dostepnymi komendami
		ustaw_sprawdz:
			#napis
			la $s2, ustaw_komenda
			jal sprawdz
			bne $s6, 1, podnies_sprawdz	#nastepna komenda
			
			#pozycja
			jal spacje
			jal sprawdz_liczbe
			blt $t1, 0, blad
			bgt $t1, 159, blad
			move $t6, $t1	#x
			
			jal spacje
			jal sprawdz_liczbe
			blt $t1, 0, blad
			bgt $t1, 119, blad
			move $t7, $t1	#y
			
			#k¹t
			jal spacje
			jal sprawdz_liczbe
			blt $t1, 0, blad
			bgt $t1, 360, blad
			move $t5, $t1
			
			jal spacje
			jal srednik
			#wszystko w porzadku
			move $k0, $t6	#x
			move $k1, $t7	#y
			move $s1, $t5	#kat
			
			b wczytaj_petla
			
		podnies_sprawdz:
			jal cofnij	#cofnij na pocz¹tek linii
			#napis
			la $s2, podnies_komenda
			jal sprawdz
			bne $s6, 1, opusc_sprawdz	#nastepna komenda
			
			#w porz¹dku
			jal spacje
			jal srednik
			#ustaw flage rysowania na 0
			li $s0, 0
			b wczytaj_petla
			
		opusc_sprawdz:
			jal cofnij	#cofnij na pocz¹tek linii
			#napis
			la $s2, opusc_komenda
			jal sprawdz
			bne $s6, 1, obrot_sprawdz	#nastepna komenda
			
			#napis siê zgadza
			jal spacje
			jal srednik
			#ustaw flage rysowania na 1
			li $s0, 1
			b wczytaj_petla
			
		obrot_sprawdz:
			jal cofnij	#cofnij na pocz¹tek linii
			#napis
			la $s2, obrot_komenda
			jal sprawdz
			bne $s6, 1, kolor_sprawdz	#nastepna komenda
			
			#k¹t
			jal spacje
			jal sprawdz_liczbe
			blt $t1, 0, blad
			bgt $t1, 360, blad
			move $t7, $t1
			
			#k¹t jest poprawny, dodaj do aktualnego
			jal spacje
			jal srednik
			jal dodaj_kat
			b wczytaj_petla
			
		kolor_sprawdz:
			jal cofnij	#cofnij na pocz¹tek linii
			#napis
			la $s2, kolor_komenda
			jal sprawdz
			bne $s6, 1, naprzod_sprawdz	#nastepna komenda
			
			jal nastepna_linia
			b wczytaj_petla
			
		naprzod_sprawdz:
			jal cofnij	#cofnij na pocz¹tek linii
			#napis
			la $s2, naprzod_komenda
			jal sprawdz
			bne $s6, 1, blad	#¯ADNA KOMENDA NIE PASUJE, B£¥D
			
			#wartoœæ przesuniêcia
			jal spacje
			jal sprawdz_liczbe
			move $s5, $t1		#zapisz wartoœæ przesuniêcia pod s5
			
			jal spacje
			jal srednik
			
			jal ustaw_kolor
			jal przesuniecie	#przesun pozycjê
			b wczytaj_petla
			
###########################################
#---------- przesuwa pozycjê i nanosi zmiany w obrazie koñcowym
#---------- (stosuje algorytm Bresenhama)
przesuniecie:
	
	
#---------- zmiana wspó³rzêdnych i kierunku przyrostu
	# t2 -> kierunek przyrostu na x (-1 lub 1)
	# t7 -> kierunek przyrostu na y (-1 lub 1)
	move $s6, $s1	#k¹t
	move $s4, $ra	#adres powrotu
	li $s2, 0	#zerowanie zmiennej oznaczaj¹cej zamianê osi
	
	#sprawdzenie w której oktancie znajduje siê podany k¹t
	ble $s6, 45, do45
	ble $s6, 90, do90
	ble $s6, 135, do135
	ble $s6, 180, do180
	ble $s6, 225, do225
	ble $s6, 270, do270
	ble $s6, 315, do315
	ble $s6, 360, do360
	b blad
	
	do45:	li $t2, 1	#x
		li $t7, 1	#y
		b dane_poczatkowe
	do90:	li $s2, 1		## oznaczenie zamiany osi
		li $t2, 1	#x
		li $t7, 1	#y
		b odwroc_kat
	do135:	li $s2, 1		## oznaczenie zamiany osi
		li $t2, -1
		li $t7, 1
		b normalizacja_kata
	do180:	li $t2, -1
		li $t7, 1
		b normalizacja_kata
	do225:	li $t2, -1
		li $t7, -1
		b normalizacja_kata
	do270:	li $s2, 1		## oznaczenie zamiany osi
		li $t2, -1
		li $t7, -1
		b normalizacja_kata
	do315:	li $s2, 1		## oznaczenie zamiany osi
		li $t2, 1
		li $t7, -1
		b normalizacja_kata
	do360:	li $t2, 1
		li $t7, -1
		b normalizacja_kata
	
	# normalizacja kata do przedzia³u [0,90]
	normalizacja_kata:
		addi $s6, $s6, -90
		bgt $s6, 90, normalizacja_kata
		#wiêksze ni¿ 45 -> k¹t to  90 - wartoœæ
		bgt $s6, 45, odwroc_kat
		b dane_poczatkowe
		
	odwroc_kat:
		#90 - $s6
		li $a3, 90
		sub $s6, $a3, $s6	
		
#---------- dane pocz¹tkowe
	dane_poczatkowe:	
	move $ra, $s4		#adres powrotu na swoje miejsce
	# dx -> t3, dy -> t4, d -> t5
	# dx -> liczba punktów na osi x
	# dy -> liczba punktów na osi y	
	# d  -> zmienna decyzyjna -> 2 * dy - dx
	
	#dx -> przesuniecie * sin(90-a)
	la $t1, sin
	li $t3, 90
	sub $t3, $t3, $s6	# 90 - a
	sll $t3, $t3, 2		# razy 4
	add $t1, $t1, $t3	# przesun do odpowiedniego sinusa
	lwc1 $f9, ($t1)	# wczytanie wartoœci
	
	mtc1 $s5, $f5 		# ca³kowita na zmiennoprzecinkow¹
	cvt.s.w $f5, $f5 
	mul.s $f9, $f9, $f5  	# przesuniecie * sin(90-a)
	round.w.s $f9, $f9
	mfc1 $t3,$f9  		# dx -> wynik po zaokr¹gleniu
	
	#dy -> przesuniecie * sin(a)
	la $t1, sin
	move $t4, $s6
	sll $t4, $t4, 2		# razy 4
	add $t1, $t1, $t4	# przesun do odpowiedniego sinusa
	lwc1 $f10, ($t1)	# wczytanie wartoœci
	
	mtc1 $s5, $f5 		# ca³kowita na zmiennoprzecinkow¹
	cvt.s.w $f5, $f5  
	mul.s $f10, $f10, $f5  	# przesuniecie * sin(a)
	round.w.s $f10, $f10
	mfc1 $t4,$f10  		# dx -> wynik po zaokr¹gleniu
	
	oblicz_d:
	sll $t5, $t4, 1
	sub $t5, $t5, $t3 	#d = 2 * dy - dx

	# przesuniecie -> dx
	move $s5, $t3
	
#---------- wyznacza pozycjê nowego piksela w pliku bmp
	oblicz_pozycje_bmp:
	
	beqz $s5, powrot	#jeœli wszytkie przejrzane -> wyjdz

		#punkt -> pocz¹tek + (k1 * 160 + k0) * 3
		mul $t1, $k1, 160	# y * 160
		add $t1, $t1, $k0	# x
		mul $t1, $t1, 3		#trzy sk³adowe na piksel	
		move $s4, $t1	

	zapisz_piksel:
		la $t1, obraz
		add $t1, $t1, $s4	#przejdz do nowego piksela
		sb $s3, ($t1) 
		addi $t1, $t1, 1
		sb $s3, ($t1) 
		addi $t1, $t1, 1
		sb $s3, ($t1) 
		addi $t1, $t1, 1
		
		addi $s5, $s5, -1	#odejmij 1 od wartoœci przesuniêcia

#---------- wyznacza nowe po³o¿enie kolejnego piksela
	oblicz_y:	
	## k¹t od 0 do 45 stopni ##
		#add $k0, $k0, 1
		#add $k1, $k1, 1
		#dx -> t3, dy -> t4, d -> t5
		
	# ze zmian¹ osi
		beqz $s2, zwieksz_x	# jeœli zamienione osie
		add $k1, $k1, $t7	# zawsze zwiêksz y
		blt $t5, 0, ten_sam_x	# sprawdŸ zmienn¹ decyzyjn¹ -> jesli mniejsza od zera to zostaw x

		# zwiêkszanie wolnego kierunku
		add $k0, $k0, $t2	# zwieksz x
		move $t6, $t4		# dy
		sub $t6, $t6, $t3	# dy-dx
		sll $t6, $t6, 1		# razy 2
		add $t5, $t5, $t6 	# dodaj do zmiennej decyzyjnej
		b sprawdz_x
		
		# pozostawianie wolnego kierunku
		ten_sam_x:
		move $t6, $t4		# dy
		sll $t6, $t6, 1		# razy 2
		add $t5, $t5, $t6 	# dodaj do zmiennej decyzyjnej
		b sprawdz_x
		
	# bez zmian osi
		zwieksz_x:
		add $k0, $k0, $t2	# zawsze zwieksz x
		blt $t5, 0, ten_sam_y	# sprawdŸ zmienn¹ decyzyjn¹
		b zwieksz_y
		
		# pozostawianie wolnego kierunku
		ten_sam_y:
		move $t6, $t4		# dy
		sll $t6, $t6, 1		# razy 2
		add $t5, $t5, $t6 	# dodaj do zmiennej decyzyjnej
		b sprawdz_x
		
		# zwiêkszanie wolnego kierunku
		zwieksz_y:
		add $k1, $k1, $t7		#zwieksz y
		move $t6, $t4		# dy
		sub $t6, $t6, $t3	# dy-dx
		sll $t6, $t6, 1		# razy 2
		add $t5, $t5, $t6 	# dodaj do zmiennej decyzyjnej
	
#---------- jeœli nowy punkt le¿y poza obszarem -> zacznij z drugiej strony
	sprawdz_x:
		bge $k0, 160, poczatek_x
		b sprawdz_y
	
		poczatek_x:
		li $k0, 0
	
#---------- jeœli nowy punkt le¿y poza obszarem -> zacznij z drugiej strony
	sprawdz_y:
		bge $k1, 120, poczatek_y
		b oblicz_pozycje_bmp
	
		poczatek_y:
		li $k1, 0
		b oblicz_pozycje_bmp

#---------- ustawia kolor rysowania
ustaw_kolor:
	# jesli flaga rysowania równa 1 -> kolor czarny
	# w innym przypadku kolor 255 (bia³y)
	beqz $s0, bialy
	
	czarny:
	li $s3, 0
	jr $ra
	
	bialy:
	li $s3, 255
	jr $ra
		
#---------- sprawdza zgodnosc ciagów
sprawdz:	
	li $s7, 0	#znaki do cofniecia
	li $s6, 0	#zeruje flage zgodnoœci
	
	sprawdz_string:
	lb $t1, ($t9)
	lb $t2, ($s2)
	beqz $t2, sprawdz_poprawne	#udalo sie
	beq $t2, $t1, it_sprawdz
	jr $ra				#blad
	
	it_sprawdz:	
	addiu $t9, $t9, 1
	addiu $s2, $s2, 1
	addiu $s7, $s7, 1
	b sprawdz_string
	
sprawdz_poprawne:
	li $s6, 1
	jr $ra
	
#---------- sprawdza poprawnoœæ liczby
# zapisuje liczbê do t1
sprawdz_liczbe:
	lb $t1, ($t9)
	blt $t1, '0', blad
	bgt $t1, '9', blad
	#mamy piersz¹ cyfre
	addiu $t9, $t9, 1
	lb $t2, ($t9)
	blt $t2, '0', jednocyfrowa
	bgt $t2, '9', jednocyfrowa
	#mamy drug¹ cyfre
	addiu $t9, $t9, 1
	lb $t3, ($t9)
	blt $t3, '0', dwucyfrowa
	bgt $t3, '9', dwucyfrowa
	#mamy trzecia cyfre
	addiu $t9, $t9, 1
	lb $t4, ($t9)
	blt $t4, '0', trojcyfrowa
	bgt $t4, '9', trojcyfrowa
	b blad #jesli ma > 3 cyfry
	
	jednocyfrowa:
	sub $t1, $t1, '0'
	jr $ra
	
	dwucyfrowa:
	sub $t1, $t1, '0'
	sub $t2, $t2, '0'
	mul $t1, $t1, 10
	add $t1, $t1, $t2
	jr $ra
	
	trojcyfrowa:
	sub $t1, $t1, '0'
	sub $t2, $t2, '0'
	sub $t3, $t3, '0'
	mul $t1, $t1, 100	#setki
	mul $t2, $t2, 10	#dziesiatki
	add $t2, $t2, $t3 	#t2+t3
	add $t1, $t1, $t2	#t1+(t2+t3)
	jr $ra
	
#---------- omija spacje i inne spodziewane separatory
spacje:	
	lb $t1, ($t9)
	beq $t1,' ', it_spacje	#omin
	beq $t1,'[', it_spacje
	beq $t1,']', it_spacje
	beq $t1,',', it_spacje
	jr $ra
	
it_spacje:
	addiu $t9, $t9, 1
	b spacje
	
srednik:
	lb $t1, ($t9)
	beq $t1, ';', nastepna_linia
	b blad
	
nastepna_linia:
	addiu $t9, $t9, 1
	lb $t1, ($t9)
	beqz $t1, powrot	#jesli koniec pliku
	bne $t1, 10, nastepna_linia	#jesli nie -> szukamy nastêpnej linii
	#jesli enter
	addiu $t9, $t9, 1	#przesuwamy o jeden znak 
	jr $ra
	
#---------- cofa o liczbê przejrzanych znaków
cofnij:
	sub $t9, $t9, $s7
	jr $ra
	
dodaj_kat:
	add $s1, $s1, $t7
	bge $s1, 360, odejmij
	jr $ra
	
	odejmij:
	sub $s1, $s1, 360
	jr $ra

#---------- zapisuje zawartosc bufora do pliku
zapisz_plik_bmp:
	
	li $v0, 13	# open file
	la $a0, wyjscie	# file name
	li $a1 1	# write mode
	syscall

	move $a0, $v0	# file desc
	li $v0, 15	# write to file
	la $a1, bmp_naglowek	# bitmap buffer
	li $a2, 54	# buffer length
	syscall
	
	li $v0, 15	# write to file
	la $a1, obraz
	li $a2, 57600
	syscall

	li $v0, 16	# close file
	move $a0, $t1
	syscall
   	 
	jr $ra	#wroc do maina

blad:	
	li $v0, 4
	la $a0, blad_komendy
	syscall
	b koniec

koniec:
	li $v0, 10
	syscall 
