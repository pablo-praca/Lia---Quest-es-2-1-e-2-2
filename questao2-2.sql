WITH calculo_salarios AS (
    SELECT 
        e.matr,
        e.lotacao_div,
        COALESCE(SUM(v.valor), 0) AS vencimentos_totais,
        COALESCE(SUM(d.valor), 0) AS descontos_totais
    FROM 
        empregado e
    LEFT JOIN emp_venc ev ON e.matr = ev.matr
    LEFT JOIN vencimento v ON ev.cod_venc = v.cod_venc
    LEFT JOIN emp_desc ed ON e.matr = ed.matr
    LEFT JOIN desconto d ON ed.cod_desc = d.cod_desc
    GROUP BY e.matr, e.lotacao_div
),

salarios_finais AS (
    SELECT
        matr,
        lotacao_div,
        (vencimentos_totais - descontos_totais) AS salario_liquido
    FROM calculo_salarios
)

SELECT 
    d.nome AS departamento,
    COUNT(DISTINCT e.matr) AS qtd_empregados,
    ROUND(AVG(COALESCE(sf.salario_liquido, 0)), 2) AS media_salarial,
    ROUND(MAX(COALESCE(sf.salario_liquido, 0)), 2) AS maior_salario,
    ROUND(MIN(COALESCE(sf.salario_liquido, 0)), 2) AS menor_salario
FROM 
    departamento d
JOIN divisao di ON d.cod_dep = di.cod_dep
LEFT JOIN empregado e ON di.cod_divisao = e.lotacao_div
LEFT JOIN salarios_finais sf ON e.matr = sf.matr
GROUP BY d.cod_dep, d.nome
ORDER BY media_salarial DESC;