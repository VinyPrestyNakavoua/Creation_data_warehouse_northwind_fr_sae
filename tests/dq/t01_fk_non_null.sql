SELECT 'fact_ventes: clefs nulles' AS test, COUNT(*) AS nb
FROM dwh.fact_ventes
WHERE datecom_key IS NULL OR client_key IS NULL OR produit_key IS NULL;
