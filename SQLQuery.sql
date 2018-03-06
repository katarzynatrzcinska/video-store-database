/* Wyœwietl liczbê wszystkich wystawionych faktur, sumê pieniêdzy oraz œredni¹ kwotê wystawion¹ na fakturach */
SELECT  COUNT(*) AS Liczba_wystawionych_faktur, 
		SUM(Kwota_p³atnoœci) AS Razem_na_fakturach, 
		AVG(Kwota_p³atnoœci) AS Œrednia_kwota_na_fakturach
FROM Faktury 

/* Wyœwietl minimaln¹ i maksymaln¹ p³acê ekspedienta w wypo¿yczalni */
SELECT  MIN(Stawka_godzinna) AS Minimalna_p³aca_ekspedienta,
		MAX(Stawka_godzinna) AS Maksymalna_p³aca_ekspedienta
FROM Pracownicy 
WHERE Stanowisko='Ekspedient';

/* Poka¿ dane (identyfikator filmu, tytu³ polski i status), jakie filmy s¹ dostêpne na pó³kach "N-P" i "I-K", 
   porz¹dkuj¹c je od najtañszych do najdro¿szych  */
SELECT DISTINCT Ident_filmu, Tytu³_polski, Status_kopii, Cena
	FROM Kopie
	JOIN Filmy ON Filmy.ISAN = Kopie.Ident_filmu
	WHERE Lokalizacja IN ('I-K', 'N-P') AND Status_kopii = 'Dostêpny'
	ORDER BY Cena

/* Uszereguj kopie od najchêtniej do najrzadziej wypo¿yczanych, znajduj¹cych siê na pozycjach wypo¿yczenia. */
SELECT Tytu³_polski, COUNT(*) AS Liczba_wypo¿yczeñ
	FROM Pozycje_wypo¿yczenia
	JOIN Kopie ON Pozycje_wypo¿yczenia.Nr_ident_kopii = Kopie.Nr_kopii
	JOIN Filmy ON Kopie.Ident_filmu = Filmy.ISAN
	GROUP BY Tytu³_polski
	ORDER BY 2 DESC;

/* Dla ka¿dego ekspedienta, który przyj¹³ co najmniej trzy zamówienia, oblicz sumê kwot przyjêtych wypo¿yczeñ, 
   szereguj¹c od tego, który zarobi³ dla wypo¿yczalni najwiêcej */
SELECT Nr_ident_przyjmuj¹cego_wypo¿yczenie, SUM(P³atnoœæ_za_wypo¿yczenie) AS Suma_przyjêtych_wypo¿yczeñ
	FROM Wypo¿yczenia
	GROUP BY Nr_ident_przyjmuj¹cego_wypo¿yczenie
	HAVING COUNT(Nr_ident_przyjmuj¹cego_wypo¿yczenie) > 3
	ORDER BY 2 DESC; 

/* Podaj informacje o wszystkich kopiach filmu "Nietykalni", podaj¹c numer kopii i jej status */
SELECT Nr_kopii, Status_kopii
	FROM Filmy  
	JOIN Kopie ON ISAN = Ident_filmu
	WHERE Tytu³_polski='Nietykalni';

/* Dla ka¿dego pracownika poka¿ jego szefa */
SELECT Podw.ID_osoby, Podw.Stanowisko, OsobyPodw.Imiê, OsobyPodw.Nazwisko, 'Jest_podwladnym', Szef.ID_osoby, Szef.Stanowisko, OsobySzef.Imiê, OsobySzef.Nazwisko
	FROM Pracownicy Podw 
	JOIN Pracownicy Szef ON Podw.Nr_ident_szefa = Szef.ID_osoby
	JOIN Osoby OsobyPodw ON Podw.ID_osoby = OsobyPodw.ID_osoby
	JOIN Osoby OsobySzef ON Podw.Nr_ident_szefa = OsobySzef.ID_osoby

/* Ka¿demu klientowi poka¿ historiê jego wypo¿yczeñ */
CREATE VIEW HistoriaWypozyczen (ID_Osoby, Imiê, Nazwisko, Data_wypo¿yczenia, Tytu³_filmu)
	AS SELECT Klienci.ID_osoby, Osoby.Imiê, Osoby.Nazwisko, Data_wypo¿yczenia, Filmy.ISAN
		FROM Klienci
		JOIN Osoby ON Klienci.ID_Osoby = Osoby.ID_Osoby
		JOIN Wypo¿yczenia ON Nr_ident_klienta = Klienci.ID_osoby
		JOIN Pozycje_wypo¿yczenia ON Pozycje_wypo¿yczenia.Nr_wypo¿yczenia = Wypo¿yczenia.Nr_wypo¿yczenia
		JOIN Kopie ON Pozycje_wypo¿yczenia.Nr_ident_kopii = Kopie.Nr_kopii
		JOIN Filmy ON Filmy.ISAN = Kopie.Ident_filmu
			WITH CHECK OPTION

-- DROP VIEW HistoriaWypozyczen

SELECT * 
	FROM HistoriaWypozyczen
	ORDER BY ID_Osoby

/* Poka¿ dane o filmach, które s¹ aktualnie dostêpne w wypo¿yczalni */
SELECT * 
	FROM Filmy
	WHERE EXISTS
		(SELECT Status_kopii
			FROM Kopie
			WHERE Kopie.Ident_filmu = Filmy.ISAN 
				  AND Kopie.Status_kopii = 'Dostêpny');


/* Poka¿ szefów, którzy maj¹ podw³adnych */
SELECT Szef.ID_osoby, Osoby.Imiê, Osoby.Nazwisko
	FROM Pracownicy Szef
	JOIN Osoby ON Szef.ID_osoby = Osoby.ID_osoby
		WHERE EXISTS
			(SELECT *
				FROM Pracownicy Podw
				WHERE Szef.ID_osoby = Podw.Nr_ident_szefa)