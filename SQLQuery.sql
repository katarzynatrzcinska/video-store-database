/* Wy�wietl liczb� wszystkich wystawionych faktur, sum� pieni�dzy oraz �redni� kwot� wystawion� na fakturach */
SELECT  COUNT(*) AS Liczba_wystawionych_faktur, 
		SUM(Kwota_p�atno�ci) AS Razem_na_fakturach, 
		AVG(Kwota_p�atno�ci) AS �rednia_kwota_na_fakturach
FROM Faktury 

/* Wy�wietl minimaln� i maksymaln� p�ac� ekspedienta w wypo�yczalni */
SELECT  MIN(Stawka_godzinna) AS Minimalna_p�aca_ekspedienta,
		MAX(Stawka_godzinna) AS Maksymalna_p�aca_ekspedienta
FROM Pracownicy 
WHERE Stanowisko='Ekspedient';

/* Poka� dane (identyfikator filmu, tytu� polski i status), jakie filmy s� dost�pne na p�kach "N-P" i "I-K", 
   porz�dkuj�c je od najta�szych do najdro�szych  */
SELECT DISTINCT Ident_filmu, Tytu�_polski, Status_kopii, Cena
	FROM Kopie
	JOIN Filmy ON Filmy.ISAN = Kopie.Ident_filmu
	WHERE Lokalizacja IN ('I-K', 'N-P') AND Status_kopii = 'Dost�pny'
	ORDER BY Cena

/* Uszereguj kopie od najch�tniej do najrzadziej wypo�yczanych, znajduj�cych si� na pozycjach wypo�yczenia. */
SELECT Tytu�_polski, COUNT(*) AS Liczba_wypo�ycze�
	FROM Pozycje_wypo�yczenia
	JOIN Kopie ON Pozycje_wypo�yczenia.Nr_ident_kopii = Kopie.Nr_kopii
	JOIN Filmy ON Kopie.Ident_filmu = Filmy.ISAN
	GROUP BY Tytu�_polski
	ORDER BY 2 DESC;

/* Dla ka�dego ekspedienta, kt�ry przyj�� co najmniej trzy zam�wienia, oblicz sum� kwot przyj�tych wypo�ycze�, 
   szereguj�c od tego, kt�ry zarobi� dla wypo�yczalni najwi�cej */
SELECT Nr_ident_przyjmuj�cego_wypo�yczenie, SUM(P�atno��_za_wypo�yczenie) AS Suma_przyj�tych_wypo�ycze�
	FROM Wypo�yczenia
	GROUP BY Nr_ident_przyjmuj�cego_wypo�yczenie
	HAVING COUNT(Nr_ident_przyjmuj�cego_wypo�yczenie) > 3
	ORDER BY 2 DESC; 

/* Podaj informacje o wszystkich kopiach filmu "Nietykalni", podaj�c numer kopii i jej status */
SELECT Nr_kopii, Status_kopii
	FROM Filmy  
	JOIN Kopie ON ISAN = Ident_filmu
	WHERE Tytu�_polski='Nietykalni';

/* Dla ka�dego pracownika poka� jego szefa */
SELECT Podw.ID_osoby, Podw.Stanowisko, OsobyPodw.Imi�, OsobyPodw.Nazwisko, 'Jest_podwladnym', Szef.ID_osoby, Szef.Stanowisko, OsobySzef.Imi�, OsobySzef.Nazwisko
	FROM Pracownicy Podw 
	JOIN Pracownicy Szef ON Podw.Nr_ident_szefa = Szef.ID_osoby
	JOIN Osoby OsobyPodw ON Podw.ID_osoby = OsobyPodw.ID_osoby
	JOIN Osoby OsobySzef ON Podw.Nr_ident_szefa = OsobySzef.ID_osoby

/* Ka�demu klientowi poka� histori� jego wypo�ycze� */
CREATE VIEW HistoriaWypozyczen (ID_Osoby, Imi�, Nazwisko, Data_wypo�yczenia, Tytu�_filmu)
	AS SELECT Klienci.ID_osoby, Osoby.Imi�, Osoby.Nazwisko, Data_wypo�yczenia, Filmy.ISAN
		FROM Klienci
		JOIN Osoby ON Klienci.ID_Osoby = Osoby.ID_Osoby
		JOIN Wypo�yczenia ON Nr_ident_klienta = Klienci.ID_osoby
		JOIN Pozycje_wypo�yczenia ON Pozycje_wypo�yczenia.Nr_wypo�yczenia = Wypo�yczenia.Nr_wypo�yczenia
		JOIN Kopie ON Pozycje_wypo�yczenia.Nr_ident_kopii = Kopie.Nr_kopii
		JOIN Filmy ON Filmy.ISAN = Kopie.Ident_filmu
			WITH CHECK OPTION

-- DROP VIEW HistoriaWypozyczen

SELECT * 
	FROM HistoriaWypozyczen
	ORDER BY ID_Osoby

/* Poka� dane o filmach, kt�re s� aktualnie dost�pne w wypo�yczalni */
SELECT * 
	FROM Filmy
	WHERE EXISTS
		(SELECT Status_kopii
			FROM Kopie
			WHERE Kopie.Ident_filmu = Filmy.ISAN 
				  AND Kopie.Status_kopii = 'Dost�pny');


/* Poka� szef�w, kt�rzy maj� podw�adnych */
SELECT Szef.ID_osoby, Osoby.Imi�, Osoby.Nazwisko
	FROM Pracownicy Szef
	JOIN Osoby ON Szef.ID_osoby = Osoby.ID_osoby
		WHERE EXISTS
			(SELECT *
				FROM Pracownicy Podw
				WHERE Szef.ID_osoby = Podw.Nr_ident_szefa)