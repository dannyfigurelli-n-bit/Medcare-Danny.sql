// Criação das Tabelas

create table clientes(
	id serial primary key,
	nome varchar(100) not null,
	email varchar(100) unique not null,
	telefone varchar(20) not null,
	cpf varchar(11) unique not null,
	data_cadastro timestamp default current_timestamp
);

create table mecanicos(
	id serial primary key,
	nome varchar(100) not null,
	especialidade varchar(150) not null,
	valor_hora decimal(10, 2) not null check(valor_hora > 0)
);

create table veiculos(
	id serial primary key,
	cliente_id int,
	placa varchar(7) unique not null,
	modelo varchar(100) not null,
	marca varchar(100) not null,
	ano int not null,

	constraint fk_veiculos_clientes
	foreign key (cliente_id)
	references clientes(id)
	on delete cascade
);

create table ordens_servico(
	id serial primary key,
	veiculo_id int,
	mecanico_id int,
	data_abertura timestamp default current_timestamp,
	valor_mao_obra decimal(10, 2) not null check(valor_mao_obra >= 0),
	status varchar(20) default 'em aberto' check(status in ('em aberto', 'em andamento', 'concluida', 'cancelada')),

	constraint fk_os_veiculos
	foreign key (veiculo_id)
	references veiculos(id)
	on delete restrict,

	constraint fk_os_mecanicos
	foreign key (mecanico_id)
	references mecanicos(id)
	on delete restrict
);

create table pecas_os(
	id serial primary key,
	os_id int,
	nome_peca varchar(100) not null,
	quantidade int not null,
	valor_unitario decimal(10, 2) not null check(valor_unitario > 0),

	constraint fk_pecas_os
	foreign key (os_id)
	references ordens_servico(id)
	on delete cascade
);

// Preenchendo as Tabelas

INSERT INTO clientes (nome, email, telefone, cpf) VALUES
('Carlos Silva', 'carlos.silva@email.com', '11988887777', '12345678901'),
('Ana Maria Souza', 'ana.souza@email.com', '21977776666', '98765432100'),
('Roberto Santos', 'roberto.santos@email.com', '31966665555', '45678912344');

INSERT INTO mecanicos (nome, especialidade, valor_hora) VALUES
('João Pereira', 'Injeção Eletrônica e Motor', 120.00),
('Marcos Oliveira', 'Suspensão e Freios', 100.00),
('Lucas Fernandes', 'Elétrica e Ar Condicionado', 110.00);

INSERT INTO veiculos (cliente_id, placa, modelo, marca, ano) VALUES
(1, 'ABC1D23', 'Civic', 'Honda', 2020),
(2, 'XYZ9K88', 'Onix', 'Chevrolet', 2021),
(3, 'MNO4E55', 'Corolla', 'Toyota', 2019);

INSERT INTO ordens_servico (veiculo_id, mecanico_id, valor_mao_obra, status) VALUES
(1, 1, 360.00, 'concluida'),
(2, 2, 200.00, 'em andamento'),
(3, 3, 220.00, 'em aberto'),
(1, 2, 150.00, 'concluida');

INSERT INTO pecas_os (os_id, nome_peca, quantidade, valor_unitario) VALUES
(1, 'Jogo de Velas de Ignição', 1, 250.00),
(1, 'Filtro de Combustível', 1, 45.00),
(2, 'Pastilha de Freio Dianteira', 1, 180.00),
(3, 'Gás Refrigerante R134a', 2, 90.00);

// Perguntas

1- select
	veiculos.marca,
	veiculos.modelo,
	veiculos.placa,
	veiculos.ano,
	clientes.nome,
	clientes.telefone
from
	veiculos
inner join
	clientes on veiculos.cliente_id = clientes.id
order by
	veiculos.marca asc, veiculos.modelo asc;

2- select
	ordens_servico.id,
	ordens_servico.data_abertura,
	ordens_servico.status,
	veiculos.placa,
	veiculos.modelo,
	mecanicos.nome
from
	ordens_servico
inner join
	veiculos on veiculos.id = ordens_servico.veiculo_id
inner join
	mecanicos on mecanicos.id = ordens_servico.mecanico_id
inner join
	clientes on clientes.id = veiculos.cliente_id
where
	clientes.nome = 'Ana Maria Souza'
order by
	ordens_servico.data_abertura desc;

3- select
	ordens_servico.id,
	ordens_servico.mecanico_id,
	ordens_servico.valor_mao_obra,
	ordens_servico.status,
	ordens_servico.veiculo_id,
	pecas_os.os_id,
	pecas_os.valor_unitario,
	mecanicos.id,
	mecanicos.nome,
	veiculos.id,
	veiculos.placa,
	 COALESCE(SUM(pecas_os.quantidade * pecas_os.valor_unitario), 0.00) AS total_pecas,
	 (ordens_servico.valor_mao_obra + coalesce(sum(pecas_os.quantidade * pecas_os.valor_unitario), 0.00)) as valor_total_os
from
	ordens_servico
inner join
	veiculos on ordens_servico.veiculo_id = veiculos.id
inner join
	mecanicos on ordens_servico.mecanico_id = mecanicos.id
inner join
	pecas_os on pecas_os.os_id = ordens_servico.id
GROUP BY ordens_servico.id, veiculos.placa, mecanicos.nome, ordens_servico.valor_mao_obra, pecas_os.os_id, pecas_os.valor_unitario, mecanicos.id, veiculos.id 
ORDER BY ordens_servico.id;

4- select
	m.nome,
	m.valor_hora
from
	mecanicos m
where
	m.valor_hora > 100

5- SELECT 
    m.especialidade,
    COUNT(os.id) AS qtd_servicos_concluidos,
    COALESCE(SUM(os.valor_mao_obra), 0.00) AS faturamento_mao_obra
FROM mecanicos m
LEFT JOIN ordens_servico os ON m.id = os.mecanico_id AND os.status = 'Concluida'
GROUP BY m.especialidade
ORDER BY faturamento_mao_obra DESC;
