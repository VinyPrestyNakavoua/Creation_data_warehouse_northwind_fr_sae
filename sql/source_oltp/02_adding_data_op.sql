
-- Insertion des données
INSERT INTO public._categorie (codecateg, nomcateg, description) VALUES
(1, 'Boissons', 'Boissons, cafés, thés, bières'),
(2, 'Condiments Sauces', 'Assaisonnements et épices'),
(3, 'Desserts', 'Desserts et friandises'),
(4, 'Produits laitiers', 'Fromages'),
(5, 'Pâtes et céréales', 'Pains, biscuits, pâtes & céréales'),
(6, 'Viandes', 'Viandes préparées'),
(7, 'Produits secs', 'Fruits secs, raisins secs, autres'),
(8, 'Poissons et fruits de mer', 'Poissons, fruits de mer, escargots');

INSERT INTO public._transporteur (notran, nomtran, tel) VALUES
(1, 'Speedy Express', '(503) 555-9831'),
(2, 'Forfait United', '(503) 555-3199'),
(3, 'Expédition fédérale', '(503) 555-9931');

INSERT INTO public._employe (noemp, nom, prenom, fonction, titrecourtoisie, datenaissance, dateembauche, adresse, ville, region, codepostal, pays, teldom, extension, rendcomptea) VALUES
(1,'Davolio','Nancy','Représentant(e)','Mlle','08DEC1968:00:00:00','01MAY2012:00:00:00','507 - 20th Ave. E. Apt. 2A','Seattle','WA','98122','Etats-Unis','(206) 555-9857',5467,'2'),
(2,'Fuller','Andrew','Vice-Président','Dr.','19FEB1972:00:00:00','14AUG2012:00:00:00','908 W. Capital Way','Tacoma','WA','98401','Etats-Unis','(206) 555-9482',3457,''),
(3,'Leverling','Janet','Représentant(e)','Mlle','30AUG1983:00:00:00','01APR2012:00:00:00','722 Moss Bay Blvd.','Kirkland','WA','98033','Etats-Unis','(206) 555-3412',3355,'2'),
(4,'Peacock','Margaret','Représentant(e)','Mme','19SEP1957:00:00:00','03MAY2013:00:00:00','4110 Old Redmond Rd.','Redmond','WA','98052','Etats-Unis','(206) 555-8122',5176,'2'),
(5,'Buchanan','Steven','Chef des ventes','M.','04MAR1975:00:00:00','17OCT2013:00:00:00','14 Garrett Hill','Londres','unknown','SW1 8JR','Royaume-Uni','(71) 555-4848',345,'2'),
(6,'Suyama','Michael','Représentant(e)','M.','02JUL1983:00:00:00','17OCT2013:00:00:00','Coventry House Miner Rd.','Londres','unknown','EC2 7JR','Royaume-Uni','(71) 555-7773',428,'7'),
(7,'Emery','Patrick','Chef des ventes','M.','29MAY1980:00:00:00','02JAN2014:00:00:00','Edgeham Hollow Winchester Way','Londres','unknown','RG1 9SP','Royaume-Uni','(71) 555-5598',465,'5'),
(8,'Callahan','Laura','Assistante commerciale','Mlle','09JAN1978:00:00:00','05MAR2014:00:00:00','4726 - 11th Ave. NE','Seattle','WA','98105','Etats-Unis','(206) 555-1189',2344,'2'),
(9,'Dodsworth','Anne','Représentant(e)','Mlle','27JAN1986:00:00:00','15NOV2014:00:00:00','7 Houndstooth Rd.','London','unknown','WG2 7LT','Royaume-Uni','(71) 555-4444',452,'5'),
(10,'Suyama','Jordan','Représentant(e)','M.','02JUL1983:00:00:00','21OCT2013:00:00:00','Coventry House Miner Rd.','Londres','unknown','EC2 7JR','Royaume-Uni','(71) 555-7773',428,'7');


\copy operationnel._client (
  codecli, societe, contact, fonction, adresse, ville, region,
  codepostal, pays, tel, fax
) FROM 'data/client.csv'
  WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'LATIN1');

\copy operationnel._commande (
  nocom, codecli, noemp, datecom, dateobjliv, dateenv,
  notran, port, destinataire, adrliv, villeliv, regionliv, codepostalliv, paysliv
) FROM 'data/commande.csv'
  WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'LATIN1');

\copy operationnel._detailcommande (
  nocom, refprod, prixunit, qte, remise
) FROM 'data/detcommande.csv'
  WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'LATIN1');

\copy operationnel._fournisseur (
  nofourn, societe, contact, fonction, adresse, ville, region,
  codepostal, pays, tel, fax, pageaccueil
) FROM 'data/fournisseurs.csv'
  WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'LATIN1');

\copy operationnel._produit (
  refprod, nomprod, nofourn, codecateg, qteparunit, prixunit,
  unitstock, unitescom, niveaureap, indisponible
) FROM 'data/produits.csv'
  WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'LATIN1');


