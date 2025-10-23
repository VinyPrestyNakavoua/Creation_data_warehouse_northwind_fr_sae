CREATE INDEX IF NOT EXISTS ix_fact_ventes_date ON dwh.fact_ventes(datecom_key);
CREATE INDEX IF NOT EXISTS ix_fact_livraisons_dateenv ON dwh.fact_livraisons(dateenv_key);
VACUUM ANALYZE dwh.fact_ventes;
VACUUM ANALYZE dwh.fact_livraisons;
