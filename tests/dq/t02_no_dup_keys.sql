SELECT 'fact_livraisons: doublons nocom' AS test, COUNT(*) AS nb
FROM (
  SELECT nocom FROM dwh.fact_livraisons GROUP BY nocom HAVING COUNT(*) > 1
) t;
