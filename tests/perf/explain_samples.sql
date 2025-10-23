-- pour performance, permettant de voir les requetes 
-- couteuses, performantes, ...
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.nomcateg, p.nomprod, SUM(f.montant_net)
FROM dwh.fact_ventes f
JOIN dwh.dim_produit p   ON p.produit_key = f.produit_key
JOIN dwh.dim_categorie c ON c.categorie_key = f.categorie_key
WHERE f.datecom_key BETWEEN 20230101 AND 20231231
GROUP BY c.nomcateg, p.nomprod;
