EXPLAIN ANALYZE
SELECT c.nomcateg, p.nomprod, SUM(f.montant_net)
FROM dw.fact_ventes f
JOIN dw.dim_produit p ON p.produit_key = f.produit_key
JOIN dw.dim_categorie c ON c.categorie_key = f.categorie_key
GROUP BY c.nomcateg, p.nomprod;
