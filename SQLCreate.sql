CREATE TABLE Gatunki (
    Id_gatunku          INTEGER				PRIMARY KEY,
    Nazwa				VARCHAR(20)			NOT NULL UNIQUE,
)

CREATE TABLE Filmy (
    ISAN                CHAR(33)			PRIMARY KEY,
    Tytu�_polski        VARCHAR(100),
    Tytu�_oryginalny    VARCHAR(100)		NOT NULL,
    Rok_produkcji	    INTEGER				NOT NULL,
    Re�yser             VARCHAR(200)		NOT NULL,
    Producent           VARCHAR(100)		NOT NULL,
    Obsada              VARCHAR(1000)		NOT NULL       
) 

CREATE TABLE FilmyGatunki (
	ISAN_filmu			CHAR(33)			REFERENCES Filmy, 
	ID_gatunku			INTEGER				NOT NULL REFERENCES Gatunki,
	PRIMARY KEY(ISAN_filmu, Id_gatunku)
)

CREATE TABLE Kopie (
    Nr_kopii            INTEGER				PRIMARY KEY,
    Lokalizacja         CHAR(3)				NOT NULL,
    Status_kopii        VARCHAR(13)			CHECK (Status_kopii='Dost�pny' OR Status_kopii='Wypo�yczony' OR Status_kopii='Zarezerwowany'),
    Ilo��_dni_do_zwrotu INTEGER				NOT NULL,
	Cena				DECIMAL(6,2)		NOT NULL,
    Ident_filmu         CHAR(33)			NOT NULL REFERENCES Filmy
)

CREATE TABLE No�niki (
    Nr_w_kolekcji       INTEGER				PRIMARY KEY,
    Rodzaj_no�nika      VARCHAR(7)			CHECK (Rodzaj_no�nika='CD-R' OR Rodzaj_no�nika='CD-RV' OR Rodzaj_no�nika='DVD' OR Rodzaj_no�nika='Blu-ray'),
    D�ugo��_nagrania    DECIMAL(6,2)		NOT NULL,
    Nr_ident_kopii      INTEGER				NOT NULL REFERENCES Kopie
)

CREATE TABLE Adresy (
    ID_adresu           INTEGER				PRIMARY KEY,
    Miasto              VARCHAR(30)			NOT NULL,
    Ulica               VARCHAR(30)			NOT NULL,
    Kod_pocztowy        CHAR(6)				NOT NULL,
    Mieszkanie          INTEGER				NOT NULL
)

CREATE TABLE Osoby (
    ID_osoby            INTEGER				PRIMARY KEY,
    Imi�                VARCHAR(30)			NOT NULL,
    Nazwisko            VARCHAR(50)			NOT NULL,
    Nr_telefonu         CHAR(9),
    Adres_email         VARCHAR(50)
)

CREATE TABLE Klienci (
    Data_dodania        DATE				NOT NULL,
    ID_osoby            INTEGER				REFERENCES Osoby	PRIMARY KEY,
    Nr_ident_adresu     INTEGER				REFERENCES Adresy,
)

CREATE TABLE Pracownicy (
    Stanowisko          VARCHAR(10)			CHECK (Stanowisko='Dyrektor' OR Stanowisko='Ekspedient' OR Stanowisko='Sprz�tacz'),
    Stawka_godzinna     DECIMAL(6,2)		NOT NULL,
    Data_przyj�cia      DATE				NOT NULL			CHECK ( Data_przyj�cia >= '2016-05-01' ),
    ID_osoby			INTEGER				REFERENCES Osoby	PRIMARY KEY,
    Nr_ident_adresu     INTEGER				REFERENCES Adresy,    
    Nr_ident_szefa      INTEGER				REFERENCES Pracownicy,
)

CREATE TABLE Rezerwacje (
    Nr_rezerwacji       INTEGER				PRIMARY KEY,
    Na_kiedy            DATE				NOT NULL,
    Nr_ident_kopii      INTEGER				NOT NULL REFERENCES Kopie,      
    Nr_ident_klienta    INTEGER				REFERENCES Klienci
)

CREATE TABLE Wypo�yczenia (
    Nr_wypo�yczenia			INTEGER				PRIMARY KEY,
    Data_wypo�yczenia		DATE				NOT NULL,
    Naliczone_kary			DECIMAL(6,2),
    P�atno��_za_wypo�yczenie    DECIMAL(6,2)	NOT NULL,
    Nr_ident_klienta            INTEGER			NOT NULL REFERENCES Klienci,
    Nr_ident_przyjmuj�cego_wypo�yczenie INTEGER NOT NULL REFERENCES Pracownicy
)

CREATE TABLE Pozycje_wypo�yczenia (
    Lp						INTEGER,
    Rabat					DECIMAL(6,2)		NOT NULL,
    Data_zwrotu_faktycznego DATE,
    Nr_ident_kopii			INTEGER				NOT NULL REFERENCES Kopie, 
    Nr_wypo�yczenia			INTEGER				NOT NULL REFERENCES Wypo�yczenia,
    PRIMARY KEY(Nr_wypo�yczenia, Lp)
)

CREATE TABLE Faktury (
    Nr_faktury            INTEGER				PRIMARY KEY,
    Kwota_p�atno�ci       DECIMAL(6,2)			NOT NULL,
    Nr_ident_wypo�yczenia INTEGER				NOT NULL REFERENCES Wypo�yczenia
)