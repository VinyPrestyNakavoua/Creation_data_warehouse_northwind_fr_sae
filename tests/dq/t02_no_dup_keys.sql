-- Vérifie l'unicité nocom dans fact_livraisons (grain = 1 par commande)
SELECT 'fact_livraisons: doublons nocom' AS test, COUNT(*) AS nb
FROM (
  SELECT nocom FROM dw.fact_livraisons GROUP BY nocom HAVING COUNT(*) > 1
) t;
