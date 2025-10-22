-- Vérifie que les FK essentielles ne sont pas NULL dans fact_ventes
SELECT 'fact_ventes: clefs nulles' AS test, COUNT(*) AS nb
FROM dw.fact_ventes
WHERE datecom_key IS NULL OR client_key IS NULL OR produit_key IS NULL;
