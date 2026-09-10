// Criação das tabelas

create table pacientes(
	id serial primary key,
	nome varchar(100) not null,
	email varchar(100) unique not null,
	cpf varchar(11) unique not null,
	data_nascimento date not null,
	data_cadastro timestamp default current_timestamp
);

create table especialidades(
	id serial primary key,
	nome varchar(100) unique not null
);

create table medicos(
	id serial primary key,
	especialidade_id int not null,
	nome varchar(100) not null,
	crm varchar(100) unique not null,
	valor_consulta decimal(10, 2) not null check (valor_consulta > 0),

	constraint fk_medico_especialidade
	foreign key (especialidade_id)
	references especialidades(id)
	on delete restrict
);

create table consultas(
	id serial primary key,
	medico_id int not null,
	paciente_id int not null,
	data_hora timestamp not null,
	status varchar(20) default 'agenda' check (status in('agendada', 'realizada', 'cancelada')),

	CONSTRAINT fk_consulta_medico 
        FOREIGN KEY (medico_id) 
        REFERENCES medicos(id) 
        ON DELETE RESTRICT,
    CONSTRAINT fk_consulta_paciente 
        FOREIGN KEY (paciente_id) 
        REFERENCES pacientes(id) 
        ON DELETE CASCADE
);
create table exames_consulta(
	id serial primary key,
	 consulta_id INT NOT NULL,
    nome_exame VARCHAR(100) NOT NULL,
    valor_exame NUMERIC(10, 2) NOT NULL CHECK (valor_exame >= 0),
    
    CONSTRAINT fk_exame_consulta 
        FOREIGN KEY (consulta_id) 
        REFERENCES consultas(id) 
        ON DELETE CASCADE
);

// Inserção dos dados (*Etapa realizada com auxílio de Inteligência Artificial*)

  1 - 
INSERT INTO especialidades (nome) VALUES 
('Cardiologia'),
('Pediatria'),
('Dermatologia');

INSERT INTO medicos (especialidade_id, nome, crm, valor_consulta) VALUES 
(1, 'Dr. Roberto Alves', 'CRM/SP 123456', 350.00),
(2, 'Dra. Mariana Costa', 'CRM/SP 654321', 280.00),
(3, 'Dr. Carlos Eduardo', 'CRM/RJ 987654', 400.00);


INSERT INTO pacientes (nome, email, cpf, data_nascimento) VALUES 
('Ana Silva', 'ana.silva@email.com', '12345678901', '1990-05-15'),
('Bruno Oliveira', 'bruno.oliveira@email.com', '98765432100', '1985-10-20'),
('Carla Mendes', 'carla.mendes@email.com', '45678912344', '2001-03-08');

INSERT INTO consultas (medico_id, paciente_id, data_hora, status) VALUES 
(1, 1, '2026-03-10 14:00:00', 'realizada'),
(2, 2, '2026-03-11 09:30:00', 'realizada'),
(3, 3, '2026-03-12 11:00:00', 'agendada'),
(1, 2, '2026-03-15 16:00:00', 'cancelada');

INSERT INTO exames_consulta (consulta_id, nome_exame, valor_exame) VALUES 
(1, 'Eletrocardiograma', 120.00),
(1, 'Ecocardiograma', 250.00),
(2, 'Hemograma Completo', 45.00),
(3, 'Biópsia de Pele', 300.00);

// Questões

select 
	medicos.nome,
	medicos.crm,
	medicos.especialidade_id,
	especialidades.nome,
	medicos.valor_consulta
from
	medicos
left join
	especialidades
on
	especialidades.id = medicos.especialidade_id
order by
	medicos.valor_consulta

  2- 
SELECT
    consultas.id,
    consultas.data_hora,
    medicos.nome AS medico_nome,
    especialidades.nome AS especialidade_nome,
    consultas.status
FROM
    consultas
INNER JOIN
    pacientes ON consultas.paciente_id = pacientes.id
INNER JOIN
    medicos ON consultas.medico_id = medicos.id
INNER JOIN
    especialidades ON medicos.especialidade_id = especialidades.id
WHERE 
    pacientes.nome = 'Ana Silva'
ORDER BY 
    consultas.data_hora ASC;

  3-
SELECT 
    consultas.id AS consulta_id,
    pacientes.nome AS paciente_nome,
    medicos.nome AS medico_nome,
    (medicos.valor_consulta + COALESCE(SUM(exames_consulta.valor_exame), 0.00)) AS valor_total_calculado
FROM 
    consultas
INNER JOIN 
    pacientes ON consultas.paciente_id = pacientes.id
INNER JOIN 
    medicos ON consultas.medico_id = medicos.id
LEFT JOIN 
    exames_consulta ON consultas.id = exames_consulta.consulta_id
GROUP BY 
    consultas.id, 
    pacientes.nome, 
    medicos.nome, 
    medicos.valor_consulta
ORDER BY 
    consultas.id ASC;

  4-
SELECT 
    id,
    nome,
    crm,
    valor_consulta
FROM 
    medicos
WHERE 
    valor_consulta > 300.00;
  
  5-
select
	especialidades.id,
	especialidades.nome,
	coalesce(sum(medicos.valor_consulta), 0.00) as valor_total_especialidades
from
	especialidades
inner join
	medicos on medicos.especialidade_id = especialidades.id
inner join
	consultas on consultas.medico_id = medicos.id
where
	consultas.status = 'realizada'
group by
	especialidades.id,
    especialidades.nome
order by
valor_total_especialidades;
