use petshop;

-- relatorio 1

SELECT 
    e.nome AS 'Nome Empregado',
    e.cpf AS 'CPF Empregado',
    DATE(e.dataAdm) AS 'Data Admissão',
    FORMAT(e.salario, 2) AS 'Salário',  
    d.nome AS 'Departamento',
    GROUP_CONCAT(t.numero SEPARATOR ', ') AS 'Número de Telefone'
FROM Empregado e
LEFT JOIN Departamento d ON e.Departamento_idDepartamento = d.idDepartamento
LEFT JOIN Telefone t ON e.cpf = t.Empregado_cpf
WHERE e.dataAdm BETWEEN '2019-01-01' AND '2022-03-31 23:59:59'
GROUP BY e.cpf
ORDER BY e.dataAdm DESC;

-- relatorio 2

SELECT 
    e.nome AS 'Nome Empregado',
    e.cpf AS 'CPF Empregado',
    DATE(e.dataAdm) AS 'Data Admissão',
    CAST(e.salario AS DECIMAL(7,2)) AS 'Salário',  
    GROUP_CONCAT(t.numero SEPARATOR ', ') AS 'Número de Telefone'
FROM Empregado e
LEFT JOIN Departamento d ON e.Departamento_idDepartamento = d.idDepartamento
LEFT JOIN Telefone t ON e.cpf = t.Empregado_cpf
WHERE e.salario < (SELECT AVG(salario) FROM Empregado)
GROUP BY e.cpf, e.nome, e.dataAdm, e.salario, d.nome 
ORDER BY e.nome;

-- relatorio 3 
SELECT 
    d.nome AS 'Departamento',
    COUNT(e.cpf) AS 'Quantidade de Empregados',
    ROUND(AVG(e.salario), 2) AS 'Média Salarial',
    COALESCE(ROUND(AVG(e.comissao), 2), 0.00) AS 'Média da Comissão'
FROM Departamento d
LEFT JOIN Empregado e ON d.idDepartamento = e.Departamento_idDepartamento
GROUP BY d.idDepartamento, d.nome 
ORDER BY d.nome;

-- relatorio 4

SELECT 
    e.nome AS 'Nome Empregado',
    e.cpf AS 'CPF Empregado',
    e.sexo AS 'Sexo',
    CAST(e.salario AS DECIMAL(7,2)) AS 'Salário',
    COUNT(v.idVenda) AS 'Quantidade Vendas',
    COALESCE(SUM(v.valor), 0.00) AS 'Total Valor Vendido',
    COALESCE(SUM(v.comissao), 0.00) AS 'Total Comissão das Vendas'
FROM Empregado e
LEFT JOIN Venda v ON e.cpf = v.Empregado_cpf
GROUP BY e.cpf, e.nome, e.sexo, e.salario  
ORDER BY COUNT(v.idVenda) DESC;

-- relatorio 5

SELECT 
    e.nome AS 'Nome Empregado',
    e.cpf AS 'CPF Empregado',
    e.sexo AS 'Sexo',
    CAST(e.salario AS DECIMAL(7,2)) AS 'Salário',
    COUNT(isv.Servico_idServico) AS 'Quantidade Vendas com Serviço',
    SUM(isv.valor) AS 'Total Valor Vendido com Serviço',
    SUM((s.valorVenda - s.valorCusto) * isv.quantidade) AS 'Total Comissão das Vendas com Serviço'
FROM Empregado e
JOIN itensServico isv ON e.cpf = isv.Empregado_cpf
JOIN Servico s ON isv.Servico_idServico = s.idServico
GROUP BY e.cpf, e.nome, e.sexo, e.salario
ORDER BY COUNT(isv.Servico_idServico) DESC;

-- relatorio 6 

SELECT 
    p.nome AS 'Nome do Pet',
    DATE(v.data) AS 'Data do Serviço',
    s.nome AS 'Nome do Serviço',
    isv.quantidade AS 'Quantidade',
    CAST(isv.valor AS DECIMAL(6,2)) AS 'Valor', 
    e.nome AS 'Empregado que realizou o Serviço'
FROM PET p
JOIN itensServico isv ON p.idPET = isv.PET_idPET
JOIN Servico s ON isv.Servico_idServico = s.idServico
JOIN Venda v ON isv.Venda_idVenda = v.idVenda
JOIN Empregado e ON isv.Empregado_cpf = e.cpf
ORDER BY v.data DESC; 

-- relatorio 7

SELECT 
    DATE(v.data) AS 'Data da Venda',
    CAST(v.valor AS DECIMAL(7,2)) AS 'Valor',
    COALESCE(v.desconto, 0.00) AS 'Desconto',
    CAST(v.valor - (v.valor * COALESCE(v.desconto, 0) / 100) AS DECIMAL(7,2)) AS 'Valor Final',
    e.nome AS 'Empregado que realizou a venda'
FROM Venda v
JOIN Empregado e ON v.Empregado_cpf = e.cpf
WHERE v.Cliente_cpf IS NOT NULL  
ORDER BY v.data DESC;

-- relatorio 8
SELECT 
    s.nome AS 'Nome do Serviço',
    SUM(isv.quantidade) AS 'Quantidade Vendas',
    CAST(SUM(isv.valor) AS DECIMAL(10,2)) AS 'Total Valor Vendido'
FROM Servico s
JOIN itensServico isv ON s.idServico = isv.Servico_idServico
GROUP BY s.idServico, s.nome  
ORDER BY SUM(isv.quantidade) DESC
LIMIT 10;

-- relatorio 9 

SELECT 
    fpg.tipo AS 'Tipo Forma Pagamento',
    COUNT(fpg.Venda_idVenda) AS 'Quantidade Vendas',
    CAST(SUM(fpg.valorPago) AS DECIMAL(10,2)) AS 'Total Valor Vendido'
FROM FormaPgVenda fpg
JOIN Venda v ON fpg.Venda_idVenda = v.idVenda
GROUP BY fpg.tipo
ORDER BY COUNT(fpg.Venda_idVenda) DESC;

-- relatorio 10 

SELECT 
    DATE(v.data) AS 'Data Venda',
    COUNT(v.idVenda) AS 'Quantidade de Vendas',
    CAST(SUM(v.valor) AS DECIMAL(10,2)) AS 'Valor Total Venda'
FROM Venda v
GROUP BY DATE(v.data) 
ORDER BY DATE(v.data) DESC;  

-- relatorio 11 

SELECT 
    pr.nome AS 'Nome Produto',
    CAST(pr.valorVenda AS DECIMAL(6,2)) AS 'Valor Produto',
    pr.marca AS 'Categoria do Produto',
    f.nome AS 'Nome Fornecedor',
    f.email AS 'Email Fornecedor',
    GROUP_CONCAT(t.numero SEPARATOR ', ') AS 'Telefone Fornecedor'
FROM Produtos pr
LEFT JOIN ItensCompra ic ON pr.idProduto = ic.Produtos_idProduto
LEFT JOIN Compras c ON ic.Compras_idCompra = c.idCompra
LEFT JOIN Fornecedor f ON c.Fornecedor_cpf_cnpj = f.cpf_cnpj
LEFT JOIN Telefone t ON f.cpf_cnpj = t.Fornecedor_cpf_cnpj
GROUP BY pr.idProduto, pr.nome, pr.valorVenda, pr.marca, f.nome, f.email
ORDER BY pr.nome;

-- relatrio 12

SELECT 
    p.nome AS 'Nome Produto',
    SUM(ivp.quantidade) AS 'Quantidade (Total) Vendas',
    CAST(SUM(ivp.valor) AS DECIMAL(10,2)) AS 'Valor Total Recebido pela Venda do Produto'
FROM Produtos p
JOIN ItensVendaProd ivp ON p.idProduto = ivp.Produto_idProduto
GROUP BY p.idProduto, p.nome
ORDER BY SUM(ivp.quantidade) DESC;



