/*
Nome: André Moreira Souza    N°USP: 9778985
Prática 4 - Índices
*/

-- Parte 1A ------------------------------------------------------------------------------------------------------------
/*
Após cada inserção, o índice ativo deve ser reajustado, em disco, e isso é uma operação muito cara, causando o grande overhead observado. Sem o índice ativo, não existe este overhead de reindexação.
Esse processo de inserção individual de tuplas, seguida da atualização do índice é chamada "atualização por instância". Utilizando bulk-load ("carga rápida"), é possível fazer uma inserção de um grande volume de tuplas, agrupando-as em blocos e inserindo na base de dados. Assim, o índice deve ser ajustado apenas uma vez, diminuindo consideravelmente o custo de inserção para cada tupla.
*/

-- Parte 1B ------------------------------------------------------------------------------------------------------------
-- Exercício 1B-1 ------------------------------------------------------------------------------------------------------
EXPLAIN PLAN FOR SELECT A.Nome, M.Turma
  FROM ESQUEMA_ALUNOS.Alunos A JOIN ESQUEMA_ALUNOS.Matricula M
  ON A.NUSP = M.NUSP
  WHERE A.NUSP = 37911061;
SELECT plan_table_output FROM TABLE (dbms_xplan.display());

/*
--------------------------------------------------------------------------------
| Id  | Operation          | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |           |     9 |   297 |  1242   (2)| 00:00:15 |
|*  1 |  HASH JOIN         |           |     9 |   297 |  1242   (2)| 00:00:15 |
|*  2 |   TABLE ACCESS FULL| ALUNOS    |     1 |    22 |   274   (1)| 00:00:04 |
|*  3 |   TABLE ACCESS FULL| MATRICULA |     9 |    99 |   968   (2)| 00:00:12 |
--------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - access("A"."NUSP"="M"."NUSP")
	2 - filter("A"."NUSP"=37911061)
	3 - filter("M"."NUSP"=37911061)
*/
-- Criação do índice
/*
------------------------------------------------------------------------------------------
| Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |           |     9 |   297 |   970   (2)| 00:00:12 |
|   1 |  NESTED LOOPS                |           |     9 |   297 |   970   (2)| 00:00:12 |
|   2 |   TABLE ACCESS BY INDEX ROWID| ALUNOS    |     1 |    22 |     2   (0)| 00:00:01 |
|*  3 |    INDEX UNIQUE SCAN         | PK_ALUNOS |     1 |       |     1   (0)| 00:00:01 |
|*  4 |   TABLE ACCESS FULL          | MATRICULA |     9 |    99 |   968   (2)| 00:00:12 |
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	3 - access("A"."NUSP"=37911061)
	4 - filter("M"."NUSP"=37911061)
*/

/*
O índice foi utilizado para filtrar o NUSP, e houve uma redução considerável no custo e tempo de execução. A redução poderia ser maior, mas existe um grande overhead devido à concorrência durante o experimento no laboratório.
*/

-- Exercício 1B-2 ------------------------------------------------------------------------------------------------------
EXPLAIN PLAN FOR SELECT A.Nome FROM ESQUEMA_ALUNOS.Alunos A WHERE A.Cidade LIKE 'Ap%';
SELECT plan_table_output FROM TABLE(dbms_xplan.display());
/*
----------------------------------------------------------------------------
| Id  | Operation         | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |        |   243 |  7290 |   274   (1)| 00:00:04 |
|*  1 |  TABLE ACCESS FULL| ALUNOS |   243 |  7290 |   274   (1)| 00:00:04 |
----------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter("A"."CIDADE" LIKE 'Ap%')
*/
-- Índice criado
/*
-------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |                   |   243 |  7290 |   243   (0)| 00:00:03 |
|   1 |  TABLE ACCESS BY INDEX ROWID| ALUNOS            |   243 |  7290 |   243   (0)| 00:00:03 |
|*  2 |   INDEX RANGE SCAN          | IDX_CIDADE_ALUNOS |   243 |       |     2   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	2 - access("A"."CIDADE" LIKE 'Ap%')
		 filter("A"."CIDADE" LIKE 'Ap%')
*/

/*
O índice foi utilizado para filtar o intervalo de chaves de busca que começam com a substring 'Ap', reduzindo o custo e tempo de execução.
*/

-- Exercício 1B-3-------------------------------------------------------------------------------------------------------
EXPLAIN PLAN FOR SELECT A.Nome FROM ESQUEMA_ALUNOS.Alunos A WHERE A.Cidade LIKE '%ao';
SELECT plan_table_output FROM TABLE(dbms_xplan.display());
/*
----------------------------------------------------------------------------
| Id  | Operation         | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |        |  4000 |   117K|   274   (1)| 00:00:04 |
|*  1 |  TABLE ACCESS FULL| ALUNOS |  4000 |   117K|   274   (1)| 00:00:04 |
----------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter("A"."CIDADE" LIKE '%ao' AND "A"."CIDADE" IS NOT NULL)
*/

/*
O índice está ordenando as chaves de busca em ordem alfabética. Se o SGBD optasse por utilizar o índice criado, seria necessário uma busca completa neste, o que geralmente é mais caro que o acesso sequencial na tabela. Sendo assim, o planejador de consultas decidiu que não vale a pena utilizar o índice para esta consulta.
*/
-- Exercício 1B-4-------------------------------------------------------------------------------------------------------
/*
Antes da consulta: índice Bitmap aparenta ser melhor, por ter um tamanho menor e pela baixa cardinalidade do atributo GRAU, o que implicaria em menos acessos a disco e um custo menor de execução.
*/
EXPLAIN PLAN FOR SELECT P.Nome FROM ESQUEMA_ALUNOS.Professor P WHERE P.Grau = 1;
SELECT plan_table_output FROM TABLE(dbms_xplan.display());
/*
-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |  1240 | 23560 |    13   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| PROFESSOR |  1240 | 23560 |    13   (0)| 00:00:01 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter("P"."GRAU"=1)
*/
-- Índice BITMAP criado
/*
-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |  1240 | 23560 |    13   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| PROFESSOR |  1240 | 23560 |    13   (0)| 00:00:01 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter("P"."GRAU"=1)
*/
-- Índice B-TREE criado
/*
-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |  1240 | 23560 |    13   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| PROFESSOR |  1240 | 23560 |    13   (0)| 00:00:01 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter("P"."GRAU"=1)
*/

-- Analisando outras consultas:
SELECT P.GRAU, COUNT(*) FROM ESQUEMA_ALUNOS.Professor P GROUP BY P.GRAU ORDER BY P.GRAU;
/*
GRAU COUNT(*)
1	4
2	156
3	2988
5	1981
6	1071
10	1
*/

-- Utiliza índice, pelo plano de consultas
EXPLAIN PLAN FOR SELECT P.Nome FROM ESQUEMA_ALUNOS.Professor P WHERE P.Grau >= 10;
SELECT plan_table_output FROM TABLE(dbms_xplan.display());

-- Não utiliza o índice
EXPLAIN PLAN FOR SELECT P.Nome FROM ESQUEMA_ALUNOS.Professor P WHERE P.Grau BETWEEN 6 AND 10;
SELECT plan_table_output FROM TABLE(dbms_xplan.display());

/*
O SGBD utiliza medidas estatísticas para decidir qual plano de consulta que vai utilizar. Nesta tabela, existe uma distribuição entre poucos valores para o atributo GRAU, onde para um determinado valor (GRAU=3) pode haver mais de ~48% das tuplas existentes. Por esse motivo, o planejador de consultas pode ter decidido que não vale a pena utilizar um índice.
Um caso em que o SGBD opta por utilizar o índice é quando buscamos por tuplas onde GRAU >= 10, possívelmente porque não existem as medidas estatísticas para tuplas com estes valores, ou o número esperado de tuplas resultantes é muito baixo.
*/

-- Exercício 1B-5-------------------------------------------------------------------------------------------------------
EXPLAIN PLAN FOR SELECT A.NUSP FROM ESQUEMA_ALUNOS.Alunos A WHERE A.Idade > 18;
SELECT plan_table_output FROM TABLE(dbms_xplan.display());
/*
----------------------------------------------------------------------------
| Id  | Operation         | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |        | 79219 |   696K|   274   (1)| 00:00:04 |
|*  1 |  TABLE ACCESS FULL| ALUNOS | 79219 |   696K|   274   (1)| 00:00:04 |
----------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter("A"."IDADE">18)
*/
-- Índice criado
/*
----------------------------------------------------------------------------
| Id  | Operation         | Name   | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |        | 79219 |   696K|   274   (1)| 00:00:04 |
|*  1 |  TABLE ACCESS FULL| ALUNOS | 79219 |   696K|   274   (1)| 00:00:04 |
----------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter("A"."IDADE">18)
*/
EXPLAIN PLAN FOR SELECT A.NUSP FROM ESQUEMA_ALUNOS.Alunos A WHERE A.Idade > 50;
SELECT plan_table_output FROM TABLE(dbms_xplan.display());
/*
------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |                  |   285 |  2565 |    39   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| ALUNOS           |   285 |  2565 |    39   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_IDADE_ALUNOS |   285 |       |     2   (0)| 00:00:01 |
------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	2 - access("A"."IDADE">50)
*/
/*
O otimizador consegue identificar, por medidas estatísticas, se vale a pena utilizar o índice, dependendo do valor do filtro. Para esta tabela, é esperado que uma parcela predominante (mais de 90%) das tuplas possui IDADE>18, e sendo assim pode ser mais eficiente realizar uma busca sequencial na tabela do que utilizar o índice, na primeira consulta.
Na segunda consulta, como provavelmente existem poucas tuplas para IDADE>50, o planejador de consultas decidiu por utilizar o índice.
*/

-- Exercício 1B-6-------------------------------------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT A.NUSP, A.Nome, D.Nome,(M.NotaP1 + M.NotaP2)/2 AS MEDIA , M.Frequencia
	FROM ESQUEMA_ALUNOS.Matricula M JOIN ESQUEMA_ALUNOS.Alunos A
  ON M.NUSP = A.NUSP
	JOIN ESQUEMA_ALUNOS.Turma T ON M.Turma = T.TurmaId
	JOIN ESQUEMA_ALUNOS.Discip D ON T.Disciplina = D.DiscipID
	WHERE (M.NotaP1 + M.NotaP2)/2 >= 5.0 AND M.Frequencia >= 70;
SELECT plan_table_output FROM TABLE(dbms_xplan.display());

EXPLAIN PLAN FOR
SELECT A.NUSP, A.Nome, D.Nome,(M.NotaP1 + M.NotaP2)/2 AS MEDIA , M.Frequencia
	FROM ESQUEMA_ALUNOS.Matricula M JOIN ESQUEMA_ALUNOS.Alunos A
	ON M.NUSP = A.NUSP
	JOIN ESQUEMA_ALUNOS.Turma T ON M.Turma = T.TurmaId
	JOIN ESQUEMA_ALUNOS.Discip D ON T.Disciplina = D.DiscipID
	WHERE (M.NotaP1 + M.NotaP2)/2 = 5.0 AND M.Frequencia = 70;
SELECT plan_table_output FROM TABLE(dbms_xplan.display());
/*
----------------------------------------------------------------------------------
| Id  | Operation            | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |           | 10722 |  1026K|  1352   (2)| 00:00:17 |
|*  1 |  HASH JOIN           |           | 10722 |  1026K|  1352   (2)| 00:00:17 |
|*  2 |   HASH JOIN          |           | 10722 |   795K|  1078   (3)| 00:00:13 |
|*  3 |    HASH JOIN         |           | 10722 |   335K|  1009   (3)| 00:00:13 |
|*  4 |     TABLE ACCESS FULL| MATRICULA | 10722 |   230K|   976   (3)| 00:00:12 |
|   5 |     TABLE ACCESS FULL| TURMA     | 24263 |   236K|    32   (0)| 00:00:01 |
|   6 |    TABLE ACCESS FULL | DISCIP    | 12178 |   523K|    68   (0)| 00:00:01 |
|   7 |   TABLE ACCESS FULL  | ALUNOS    | 80000 |  1718K|   273   (1)| 00:00:04 |
----------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - access("M"."NUSP"="A"."NUSP")
	2 - access("T"."DISCIPLINA"="D"."DISCIPID")
	3 - access("M"."TURMA"="T"."TURMAID")
	4 - filter("M"."FREQUENCIA">=70 AND ("M"."NOTAP1"+"M"."NOTAP2")/2>=5.0)
*/
/*
---------------------------------------------------------------------------------------------
| Id  | Operation                       | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                |           |    27 |  2646 |  1053   (2)| 00:00:13 |
|   1 |  NESTED LOOPS                   |           |       |       |            |          |
|   2 |   NESTED LOOPS                  |           |    27 |  2646 |  1053   (2)| 00:00:13 |
|   3 |    NESTED LOOPS                 |           |    27 |  1458 |  1026   (2)| 00:00:13 |
|   4 |     NESTED LOOPS                |           |    27 |   864 |   999   (2)| 00:00:12 |
|*  5 |      TABLE ACCESS FULL          | MATRICULA |    27 |   594 |   973   (2)| 00:00:12 |
|   6 |      TABLE ACCESS BY INDEX ROWID| TURMA     |     1 |    10 |     1   (0)| 00:00:01 |
|*  7 |       INDEX UNIQUE SCAN         | PK_TURMA  |     1 |       |     0   (0)| 00:00:01 |
|   8 |     TABLE ACCESS BY INDEX ROWID | ALUNOS    |     1 |    22 |     1   (0)| 00:00:01 |
|*  9 |      INDEX UNIQUE SCAN          | PK_ALUNOS |     1 |       |     0   (0)| 00:00:01 |
|* 10 |    INDEX UNIQUE SCAN            | PK_DISCIP |     1 |       |     0   (0)| 00:00:01 |
|  11 |   TABLE ACCESS BY INDEX ROWID   | DISCIP    |     1 |    44 |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	5 - filter("M"."FREQUENCIA"=70 AND ("M"."NOTAP1"+"M"."NOTAP2")/2=5.0)
	7 - access("M"."TURMA"="T"."TURMAID")
	9 - access("M"."NUSP"="A"."NUSP")
  10 - access("T"."DISCIPLINA"="D"."DISCIPID")
*/
-- Índices criados
/*
------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name                | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |                     | 10722 |  1026K|  1334   (1)| 00:00:17 |
|*  1 |  HASH JOIN                     |                     | 10722 |  1026K|  1334   (1)| 00:00:17 |
|*  2 |   HASH JOIN                    |                     | 10722 |   795K|  1059   (1)| 00:00:13 |
|*  3 |    HASH JOIN                   |                     | 10722 |   335K|   990   (1)| 00:00:12 |
|*  4 |     TABLE ACCESS BY INDEX ROWID| MATRICULA           | 10722 |   230K|   957   (1)| 00:00:12 |
|*  5 |      INDEX RANGE SCAN          | IDX_NOTAS_MATRICULA |  6294 |       |    16   (0)| 00:00:01 |
|   6 |     TABLE ACCESS FULL          | TURMA               | 24263 |   236K|    32   (0)| 00:00:01 |
|   7 |    TABLE ACCESS FULL           | DISCIP              | 12178 |   523K|    68   (0)| 00:00:01 |
|   8 |   TABLE ACCESS FULL            | ALUNOS              | 80000 |  1718K|   273   (1)| 00:00:04 |
------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - access("M"."NUSP"="A"."NUSP")
	2 - access("T"."DISCIPLINA"="D"."DISCIPID")
	3 - access("M"."TURMA"="T"."TURMAID")
	4 - filter("M"."FREQUENCIA">=70)
	5 - access(("NOTAP1"+"NOTAP2")/2>=5.0)
*/
/*
------------------------------------------------------------------------------------------------------------
| Id  | Operation                            | Name                | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |                     |    27 |  2646 |    98   (2)| 00:00:02 |
|   1 |  NESTED LOOPS                        |                     |       |       |            |          |
|   2 |   NESTED LOOPS                       |                     |    27 |  2646 |    98   (2)| 00:00:02 |
|   3 |    NESTED LOOPS                      |                     |    27 |  1458 |    71   (2)| 00:00:01 |
|   4 |     NESTED LOOPS                     |                     |    27 |   864 |    44   (3)| 00:00:01 |
|   5 |      TABLE ACCESS BY INDEX ROWID     | MATRICULA           |    27 |   594 |    17   (0)| 00:00:01 |
|   6 |       BITMAP CONVERSION TO ROWIDS    |                     |       |       |            |          |
|   7 |        BITMAP AND                    |                     |       |       |            |          |
|   8 |         BITMAP CONVERSION FROM ROWIDS|                     |       |       |            |          |
|*  9 |          INDEX RANGE SCAN            | IDX_NOTAS_MATRICULA |  2797 |       |     3   (0)| 00:00:01 |
|  10 |         BITMAP CONVERSION FROM ROWIDS|                     |       |       |            |          |
|* 11 |          INDEX RANGE SCAN            | IDX_FREQ_MATRICULA  |  2797 |       |     8   (0)| 00:00:01 |
|  12 |      TABLE ACCESS BY INDEX ROWID     | TURMA               |     1 |    10 |     1   (0)| 00:00:01 |
|* 13 |       INDEX UNIQUE SCAN              | PK_TURMA            |     1 |       |     0   (0)| 00:00:01 |
|  14 |     TABLE ACCESS BY INDEX ROWID      | ALUNOS              |     1 |    22 |     1   (0)| 00:00:01 |
|* 15 |      INDEX UNIQUE SCAN               | PK_ALUNOS           |     1 |       |     0   (0)| 00:00:01 |
|* 16 |    INDEX UNIQUE SCAN                 | PK_DISCIP           |     1 |       |     0   (0)| 00:00:01 |
|  17 |   TABLE ACCESS BY INDEX ROWID        | DISCIP              |     1 |    44 |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	9 - access(("NOTAP1"+"NOTAP2")/2=5.0)
  11 - access("M"."FREQUENCIA"=70)
  13 - access("M"."TURMA"="T"."TURMAID")
  15 - access("M"."NUSP"="A"."NUSP")
  16 - access("T"."DISCIPLINA"="D"."DISCIPID")
*/
/*
i.
Inicialmente, a segunda consulta consegue se aproveitar dos índices de atributos PRIMARY KEY e UNIQUE, conseguindo uma melhora no desempenho. Isso acontece devido aos operadores utilizados nas cláusulas WHERE das duas consultas.
ii.
Após a criação dos índices, a primeira consulta utilizou apenas o índice baseado em função para a média da matrícula. A segunda consulta, em contraste, utilizou amplamente índices de atributos PRIMARY KEY e UNIQUE, além dos novos índices criados, reduzindo drásticamente o custo (previsto) de execução.
*/

-- iii. Testando otimização
EXPLAIN PLAN FOR
SELECT M.NUSP, A.Nome, D.Nome,(M.NotaP1 + M.NotaP2)/2 AS MEDIA , M.Frequencia
	FROM ESQUEMA_ALUNOS.Matricula M
  JOIN ESQUEMA_ALUNOS.Alunos A ON M.NUSP = A.NUSP
	JOIN ESQUEMA_ALUNOS.Turma T ON M.Turma = T.TurmaId
	JOIN ESQUEMA_ALUNOS.Discip D ON T.Disciplina = D.DiscipID
	WHERE (M.NotaP1 + M.NotaP2)/2 BETWEEN 5.0 AND 10.0 AND M.Frequencia BETWEEN 70 AND 100;
SELECT plan_table_output FROM TABLE(dbms_xplan.display());

/*
No plano de consultas, reduz o custo ligeiramente, assim como o número previsto de tuplas retornadas. No entanto, acredito que nao teria uma melhora significativa em um cenário real.

------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name                | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |                     |   536 | 52528 |  1332   (1)| 00:00:16 |
|*  1 |  HASH JOIN                     |                     |   536 | 52528 |  1332   (1)| 00:00:16 |
|*  2 |   HASH JOIN                    |                     |   536 | 40736 |  1058   (1)| 00:00:13 |
|*  3 |    HASH JOIN                   |                     |   536 | 17152 |   989   (1)| 00:00:12 |
|*  4 |     TABLE ACCESS BY INDEX ROWID| MATRICULA           |   536 | 11792 |   956   (1)| 00:00:12 |
|*  5 |      INDEX RANGE SCAN          | IDX_NOTAS_MATRICULA |  3147 |       |     9   (0)| 00:00:01 |
|   6 |     TABLE ACCESS FULL          | TURMA               | 24263 |   236K|    32   (0)| 00:00:01 |
|   7 |    TABLE ACCESS FULL           | DISCIP              | 12178 |   523K|    68   (0)| 00:00:01 |
|   8 |   TABLE ACCESS FULL            | ALUNOS              | 80000 |  1718K|   273   (1)| 00:00:04 |
------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - access("M"."NUSP"="A"."NUSP")
	2 - access("T"."DISCIPLINA"="D"."DISCIPID")
	3 - access("M"."TURMA"="T"."TURMAID")
	4 - filter("M"."FREQUENCIA">=70 AND "M"."FREQUENCIA"<=100)
	5 - access(("NOTAP1"+"NOTAP2")/2>=5.0 AND ("NOTAP1"+"NOTAP2")/2<=10.0)
*/
-- Parte 2 -------------------------------------------------------------------------------------------------------------
-- Exercício 2-1 -------------------------------------------------------------------------------------------------------
EXPLAIN PLAN FOR SELECT * FROM TIME WHERE PAIS = 'Brasil';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/* Utilizou o índice da chave primária TIME para fazer a consulta.*/
EXPLAIN PLAN FOR SELECT * FROM TIME WHERE PAIS = 'BRASIL';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/* Utilizou o índice da chave primária TIME para fazer a consulta. No entanto, não retorna nenhuma tupla no resultado. */
EXPLAIN PLAN FOR SELECT * FROM TIME WHERE UPPER(PAIS) = 'BRASIL';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/* Não utiliza o índice para fazer a consulta. Sendo assim, houve um acesso sequencial, com filtragem por palavra-chave (UPPER(PAIS) = 'BRASIL'). */
EXPLAIN PLAN FOR SELECT * FROM TIME WHERE PAIS IS NULL;
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/* Não utiliza o índice para fazer a consulta. Houve o acesso sequencial, com filtro por palavra-chave (IS NULL). */
EXPLAIN PLAN FOR SELECT * FROM TIME WHERE PAIS LIKE 'Br%';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/* Utilizou o índice da chave primária. Isso somente é possível para o operador LIKE pois este está comparando apenas o início da chave de busca (utilizando um intervalo na B-tree). */
EXPLAIN PLAN FOR SELECT * FROM TIME WHERE PAIS <> 'BRASIL';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/* Não utiliza o indíce para fazer a consulta. Acesso sequencial com filtro (PAIS <> 'BRASIL'). */

/*
Apenas as consultas que utilizaram operadores ('=') e (LIKE 'Br%', comparando o início da chave de busca) utilizaram o índice. Como o número total de tuplas da tabela é pequeno, não há muita diferença na performance, mas o desempenho com o índice tenderia a ser mais significativo com um aumento no número de tuplas.
*/


-- Exercício 2-2a ------------------------------------------------------------------------------------------------------
EXPLAIN PLAN FOR SELECT T.PAIS, T.NFIFA, J.NOME, J.NFIFA FROM TIME T
	 JOIN JOGADOR J ON T.PAIS = J.TIME
	 WHERE T.PAIS LIKE 'A%';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());

/*
-----------------------------------------------------------------------------------------------
| Id  | Operation                    | Name           | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                |     8 |   376 |     8  (13)| 00:00:01 |
|*  1 |  HASH JOIN                   |                |     8 |   376 |     8  (13)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID| TIME           |     6 |    78 |     2   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN          | SYS_C001122733 |     6 |       |     1   (0)| 00:00:01 |
|*  4 |   TABLE ACCESS FULL          | JOGADOR        |    24 |   816 |     5   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - access("T"."PAIS"="J"."TIME")
	3 - access("T"."PAIS" LIKE 'A%')
		 filter("T"."PAIS" LIKE 'A%')
	4 - filter("J"."TIME" LIKE 'A%')

Interpretando o plano de consultas, é aparente que o SGBD foi capaz de usufrui do índice de chave primária da tabela TIME, mas precisou ser feita uma busca sequencial na tabela JOGADOR para recuperar os dados restantes.
*/

-- Exercício 2-2b ------------------------------------------------------------------------------------------------------

CREATE INDEX IDX_JOGADOR_TIME ON JOGADOR(TIME);

-- Exercício 2-2c ------------------------------------------------------------------------------------------------------

EXPLAIN PLAN FOR SELECT T.PAIS, T.NFIFA, J.NOME, J.NFIFA FROM TIME T
	 JOIN JOGADOR J ON T.PAIS = J.TIME
	 WHERE T.PAIS LIKE 'A%';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());

/*
-------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                  |     8 |   376 |     7  (15)| 00:00:01 |
|*  1 |  HASH JOIN                   |                  |     8 |   376 |     7  (15)| 00:00:01 |
|   2 |   TABLE ACCESS BY INDEX ROWID| TIME             |     6 |    78 |     2   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN          | SYS_C001122733   |     6 |       |     1   (0)| 00:00:01 |
|   4 |   TABLE ACCESS BY INDEX ROWID| JOGADOR          |    24 |   816 |     4   (0)| 00:00:01 |
|*  5 |    INDEX RANGE SCAN          | IDX_JOGADOR_TIME |    24 |       |     2   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - access("T"."PAIS"="J"."TIME")
	3 - access("T"."PAIS" LIKE 'A%')
		 filter("T"."PAIS" LIKE 'A%')
	5 - access("J"."TIME" LIKE 'A%')
		 filter("J"."TIME" LIKE 'A%')

Interpretando o plano de consulta, podemos ver que, com a adição do índice, não foi necessária nenhuma busca sequencial durante a consulta.
*/

/*
Neste caso, o índice criado não aparenta ter melhorado muito o desempenho, como podemos observar nos planos de consulta acima. Ambas as consultas filtram as tuplas das tabelas pelas suas respectivas palavras-chave, para então realizar a junção. A diferença está exatamente em como a filtragem foi feita (utilizando o índice ou não).
É claro que, quando o número de tuplas aumenta, pode haver uma diferença mais significativa no desempenho para esta consulta.
*/

-- Exercício 2-3a ------------------------------------------------------------------------------------------------------

-- Removendo o índice criado anteriormente
DROP INDEX IDX_JOGADOR_TIME;
EXPLAIN PLAN FOR SELECT J.TIME, COUNT(*) FROM JOGADOR J
	 GROUP BY J.TIME;
SELECT plan_table_output FROM TABLE (dbms_xplan.display());

/*
------------------------------------------------------------------------------
| Id  | Operation          | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |         |    32 |   320 |     6  (17)| 00:00:01 |
|   1 |  HASH GROUP BY     |         |    32 |   320 |     6  (17)| 00:00:01 |
|   2 |   TABLE ACCESS FULL| JOGADOR |   757 |  7570 |     5   (0)| 00:00:01 |
------------------------------------------------------------------------------

Foi feito um acesso sequencial na tabela.
*/

-- Exercício 2-3b ------------------------------------------------------------------------------------------------------
CREATE INDEX IDX_JOGADOR_TIME ON JOGADOR(TIME);

-- Exercício 2-3c ------------------------------------------------------------------------------------------------------
EXPLAIN PLAN FOR SELECT J.TIME, COUNT(*) FROM JOGADOR J
	 GROUP BY J.TIME;
SELECT plan_table_output FROM TABLE (dbms_xplan.display());

/*
-----------------------------------------------------------------------------------------
| Id  | Operation            | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |                  |    32 |   320 |     4   (0)| 00:00:01 |
|   1 |  SORT GROUP BY NOSORT|                  |    32 |   320 |     4   (0)| 00:00:01 |
|   2 |   INDEX FULL SCAN    | IDX_JOGADOR_TIME |   757 |  7570 |     4   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------

O índice criado foi utilizado na consulta, para fazer o agrupamento e contagem por valor do atributo TIME.
*/

/*
O custo de CPU estimado foi reduzido, com a utilização do índice criado.
*/

-- Exercício 2-4a ------------------------------------------------------------------------------------------------------
DROP INDEX IDX_JOGADOR_TIME;

-- Exercício 2-4b ------------------------------------------------------------------------------------------------------
EXPLAIN PLAN FOR SELECT J.NOME FROM JOGADOR J WHERE J.TIME = '&TIME';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());

/*
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |    24 |   720 |     5   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| JOGADOR |    24 |   720 |     5   (0)| 00:00:01 |
-----------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter("J"."TIME"='Brasil')

Foi feito um acesso sequencial para a chave de busca.
*/

-- Exercício 2-4c ------------------------------------------------------------------------------------------------------
CREATE INDEX IDX_JOGADOR_TIME_NOME ON JOGADOR(TIME, NOME);

-- Exercício 2-4d ------------------------------------------------------------------------------------------------------
EXPLAIN PLAN FOR SELECT J.NOME FROM JOGADOR J WHERE J.TIME = '&TIME';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());

/*
------------------------------------------------------------------------------------------
| Id  | Operation        | Name                  | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT |                       |    24 |   720 |     2   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| IDX_JOGADOR_TIME_NOME |    24 |   720 |     2   (0)| 00:00:01 |
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - access("J"."TIME"='Brasil')

Como o índice contém toda a informação necessária para esta consulta, não ocorreu nenhum acesso a disco diretamente na tabela JOGADOR.
Além disso, o SGBD se aproveitou da propriedade da B+-tree para realizar uma busca por intervalos no índice criado.
*/

-- Exercício 2-4e ------------------------------------------------------------------------------------------------------
DROP INDEX IDX_JOGADOR_TIME_NOME;
CREATE INDEX IDX_JOGADOR_NOME_TIME ON JOGADOR(NOME, TIME);

-- Exercício 2-4f ------------------------------------------------------------------------------------------------------
EXPLAIN PLAN FOR SELECT J.NOME FROM JOGADOR J WHERE J.TIME = '&TIME';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());

/*
----------------------------------------------------------------------------------------------
| Id  | Operation            | Name                  | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |                       |    24 |   720 |     3   (0)| 00:00:01 |
|*  1 |  INDEX FAST FULL SCAN| IDX_JOGADOR_NOME_TIME |    24 |   720 |     3   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter("J"."TIME"='Brasil')

Esta consulta ainda utilizou o índice. No entanto, a chave de busca é uma concatenação dos atributos NOME e TIME, ordenados em ordem alfabética. A consulta filtra a relação por time, logo o planejador optou uma busca no índice inteiro para realizar a query.
Sendo assim, é possível notar que esta consulta é mais custosa que a anterior.
*/

-- Exercício 2-5a ------------------------------------------------------------------------------------------------------
DROP INDEX IDX_JOGADOR_NOME_TIME;
DROP INDEX UK_TIME; -- O SGBD não permite que sejam removidos índices de colunas UNIQUE, sem remover a constraint.

-- Escolhendo a tabela JOGO
/*
Para esta relação, consultas frequentes seriam:
	 "Selecione os jogos em que o Time X participou", "Selecione os jogos da Fase X", Selecione os jogos da próxima semana", ...
Estas consultas geralmente trazem parcelas pequenas da tabela, então índices sobre os atributos envolvidos podem aumentar o desempenho.
Sendo assim, sugiro criar os seguintes índices:
	 - Índice bitmap para o atributo FASE
	 - Índice B-tree composto para os atributos TIME1, NUMERO
	 - Índice B-tree composto para os atributos TIME2, NUMERO
	 - Índice B-tree composto para os atributos DATAHORA
	 Obs.: Optei por índices compostos para reduzir o número de acessos a tabela principal, melhorando consultas que utilizam o atributo NUMERO. No índice simples para o atributo DATAHORA, optei desta maneira pois este pode ter uma alta cardinalidade, maior que nos demais.

*/

-- Escolhendo a tabela PARTICIPA
/*
Para esta relação, consulta frequentes seriam:
	 "Selecione todas as participações do jogador X", -- Já coberto pelo índice de PK
	 "Selecione todos as participações em que jogadores ficaram mais de X minutos em campo",
	 "Selecione os jogadores que foram escalados como titulares/reservas"
Assim como na tabela anterior, estas consultas geralmente trazem parcelas pequenas da relação. Sugiro os seguintes índices:
	 - Índice B-tree baseado em função para os minutos em campo ((HoraSaída-HoraEntrada)*24*60)
	 - Índice bitmap para o atributo ESCALACAO
*/


-- Exercício 2-5b ------------------------------------------------------------------------------------------------------


-- Consultas para teste (tabela JOGO) e criação de índices


EXPLAIN PLAN FOR SELECT NUMERO, TIME1, TIME2, DATAHORA FROM JOGO WHERE TIME1 = '&TIME' OR TIME2 = '&TIME';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/*
--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |     3 |    93 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| JOGO |     3 |    93 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter("TIME1"='Brasil' OR "TIME2"='Brasil')
*/

EXPLAIN PLAN FOR SELECT NUMERO, TIME1, TIME2, DATAHORA FROM JOGO WHERE FASE = '&FASE';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/*
--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |    48 |  2160 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| JOGO |    48 |  2160 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter("FASE"='Primeira Fase')
*/

EXPLAIN PLAN FOR SELECT NUMERO, TIME1, TIME2, DATAHORA FROM JOGO WHERE DATAHORA BETWEEN TO_DATE('&DATE1', 'DD/MM/YY') AND TO_DATE('&DATE2', 'DD/MM/YY');
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/*
---------------------------------------------------------------------------
| Id  | Operation          | Name | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |      |    16 |   496 |     3   (0)| 00:00:01 |
|*  1 |  FILTER            |      |       |       |            |          |
|*  2 |   TABLE ACCESS FULL| JOGO |    16 |   496 |     3   (0)| 00:00:01 |
---------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter(TO_DATE('14/06/22','DD/MM/YY')<=TO_DATE('18/06/22','DD/MM/
				  YY'))
	2 - filter("DATAHORA"<=TO_DATE('18/06/22','DD/MM/YY') AND
				  "DATAHORA">=TO_DATE('14/06/22','DD/MM/YY'))
*/

CREATE UNIQUE INDEX IDX_JOGO_TIME1_PK ON JOGO (TIME1 ASC, NUMERO ASC) COMPRESS 1;
CREATE UNIQUE INDEX IDX_JOGO_TIME2_PK ON JOGO (TIME2 ASC, NUMERO ASC) COMPRESS 1;
CREATE BITMAP INDEX IDX_JOGO_FASE ON JOGO(FASE ASC);
CREATE INDEX IDX_JOGO_DATAHORA_PK ON JOGO (DATAHORA ASC);

EXPLAIN PLAN FOR SELECT NUMERO, TIME1, TIME2 FROM JOGO WHERE TIME1 = '&TIME' OR TIME2 = '&TIME';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/*
--------------------------------------------------------------------------------------------
| Id  | Operation              | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |                   |     3 |    69 |     3  (34)| 00:00:01 |
|*  1 |  VIEW                  | index$_join$_001  |     3 |    69 |     3  (34)| 00:00:01 |
|*  2 |   HASH JOIN            |                   |       |       |            |          |
|   3 |    INDEX FAST FULL SCAN| IDX_JOGO_TIME1_PK |     3 |    69 |     1   (0)| 00:00:01 |
|   4 |    INDEX FAST FULL SCAN| IDX_JOGO_TIME2_PK |     3 |    69 |     1   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter("TIME1"='Brasil' OR "TIME2"='Brasil')
	2 - access(ROWID=ROWID)
*/
/*
Como esperado, o índice criado foi utilizado, pois a consulta em questão geralmente retorna uma pequena parcela das tuplas da tabela.
*/
EXPLAIN PLAN FOR SELECT NUMERO, TIME1, TIME2, DATAHORA FROM JOGO WHERE FASE = '&FASE';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/*
--------------------------------------------------------------------------
| Id  | Operation         | Name | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |      |    48 |  2160 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| JOGO |    48 |  2160 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter("FASE"='Primeira Fase')
*/
/*
----------------------------------------------------------------------------------------------
| Id  | Operation                    | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |               |     1 |    45 |     1   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID | JOGO          |     1 |    45 |     1   (0)| 00:00:01 |
|   2 |   BITMAP CONVERSION TO ROWIDS|               |       |       |            |          |
|*  3 |    BITMAP INDEX SINGLE VALUE | IDX_JOGO_FASE |       |       |            |          |
----------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	3 - access("FASE"='Final')
*/
/*
Buscando por FASE='Primeira Fase', o índice não é utilizado.
Buscando por FASE='Final', o planejador utiliza o índice.

Provavelmente, o planejador de consultas utilizou medidas estatísticas, vendo que todas as tuplas atualmente na base de dados possuem FASE='Primeira Fase', e decidiu que, quando buscando por este termo, seria mais conveniente fazer uma busca sequencial, devido ao alto número de tuplas resultantes.
*/

EXPLAIN PLAN FOR SELECT NUMERO, TIME1, TIME2, DATAHORA FROM JOGO WHERE DATAHORA BETWEEN TO_DATE('&DATE1', 'DD/MM/YY') AND TO_DATE('&DATE2', 'DD/MM/YY');
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/*
-----------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name                 | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                      |    48 |  1488 |     2   (0)| 00:00:01 |
|*  1 |  FILTER                      |                      |       |       |            |          |
|   2 |   TABLE ACCESS BY INDEX ROWID| JOGO                 |    48 |  1488 |     2   (0)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN          | IDX_JOGO_DATAHORA_PK |    48 |       |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter(TO_DATE('01/01/22','DD/MM/YY')<=TO_DATE('31/12/22','DD/MM/YY'))
	3 - access("DATAHORA">=TO_DATE('01/01/22','DD/MM/YY') AND
				  "DATAHORA"<=TO_DATE('31/12/22','DD/MM/YY'))
*/
/*
Como esperado, o índice criado foi utilizado. Vale observar que o planejador de consulta utilizou o índice, mesmo com parâmetros que fazem com que o resultado retorne todas as tuplas da tabela.
*/


-- Consultas para teste (tabela PARTICIPA) e criação de índices


EXPLAIN PLAN FOR SELECT * FROM PARTICIPA WHERE (HORASAIDA-HORAENTRADA)*24*60 >= &MINUTOS;
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/*
-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |     2 |    72 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| PARTICIPA |     2 |    72 |     3   (0)| 00:00:01 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter(("HORASAIDA"-"HORAENTRADA")*24*60>=60)
*/

EXPLAIN PLAN FOR SELECT * FROM PARTICIPA WHERE ESCALACAO = '&ESCALACAO';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/*
-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |    20 |   720 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| PARTICIPA |    20 |   720 |     3   (0)| 00:00:01 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter("ESCALACAO"='Titular')
*/

CREATE INDEX IDX_PARTICIPA_MINUTOSJOGADOS ON PARTICIPA ((HORASAIDA-HORAENTRADA)*24*60);
CREATE BITMAP INDEX IDX_PARTICIPA_ESCALACAO ON PARTICIPA (ESCALACAO);

EXPLAIN PLAN FOR SELECT * FROM PARTICIPA WHERE (HORASAIDA-HORAENTRADA)*24*60 >= &MINUTOS;
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/*
------------------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name                         | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |                              |     2 |    72 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| PARTICIPA                    |     2 |    72 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_PARTICIPA_MINUTOSJOGADOS |     1 |       |     1   (0)| 00:00:01 |
------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	2 - access(("HORASAIDA"-"HORAENTRADA")*24*60>=60)
*/
/*
O índice é utilizado, como esperado. Note que o planejador ainda opta por usá-lo, mesmo com parâmetros que retornam todas as participações com valores não-nulos para HORAENTRADA e HORASAIDA.
*/

EXPLAIN PLAN FOR SELECT * FROM PARTICIPA WHERE ESCALACAO = '&ESCALACAO';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/*
-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |    20 |   720 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| PARTICIPA |    20 |   720 |     3   (0)| 00:00:01 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter("ESCALACAO"='Titular')
*/
/*
-------------------------------------------------------------------------------
| Id  | Operation         | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |           |    20 |   720 |     3   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| PARTICIPA |    20 |   720 |     3   (0)| 00:00:01 |
-------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	1 - filter("ESCALACAO"='Reserva')
*/
/*
O planejador de consultas optou por não utilizar o índice bitmap criado. Isso provavelmente acontece por causa da distribuição dos dados entre os dois possíveis valores para ESCALACAO ('Titular', 'Reserva'), que se aproxima de 50% para cada valor.

Sendo assim, a menos que haja um alto número de tuplas, este índice não apresenterá uma grande diferença no desempenho da consulta em questão.
*/
-- Exercício 2-5c ------------------------------------------------------------------------------------------------------
/*
Os índices criados foram, em sua maioria, utilizados para as consultas de interesse. Isso sugere que eles podem gerar melhoras no desempenho geral do banco, mesmo que, no momento, isso não possa ser notado por causa do baixo número de tuplas.
Dentre os índices criados, os B-tree e baseados em consulta (e.g. minutos jogados) aparentam ser mais úteis para consultas genéricas, por serem utilizados mais frequentemente pelo planejador, com diferentes parâmetros de entrada.
Os índices Bitmap foram mais utilizados para parâmetros específicos, devido à distribuição dos dados atuais, mas podem ser mais úteis com o aumento do número de tuplas e principalmente para retornar parcelas menores da relação (e.g. FASE='Final' para a relação JOGO).
*/
-- Exercício 2-6 -------------------------------------------------------------------------------------------------------

/*
Para um índice existente (pela documentação do Oracle Database 11g), é possível (com restrições restrições específicas para cada caso):
  - Desativar ou reativar (apenas para índices baseados em função);
  - Particionar e gerenciar partições (para sistemas distribuidos);
  - Gerenciar aspectos físicos de alocação, paralelização, etc...;
  - Torná-lo inutilizável (UNUSABLE), fazendo com que ele precise ser reconstruído ou deletado e recriado;
  - Torná-lo vísivel ou invisível para o planejador/otimizador de consultas;
  - Renomear;
  - Fazer com que seja monitorado pelo SGBD, ou não;
  - Refazer o índice (REBUILD);
  - ...
*/

/*
Para a base de dados atuais, irei fazer experimentos das seguintes funcionalidades:
  - Desativar ou reativar;
  - Tornar inutilizável;
  - Tornar invisível;
  - Refazer o índice;
  - Renomear.
*/

-- Desativando o índice.
ALTER INDEX IDX_PARTICIPA_MINUTOSJOGADOS DISABLE;
EXPLAIN PLAN FOR SELECT * FROM PARTICIPA WHERE (HORASAIDA-HORAENTRADA)*24*60 >= &MINUTOS;
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/*
Não é possível realizar uma consulta que utilize o índice desativado, pois ele foi marcado como UNUSABLE após a desativação. O seguinte erro foi reportado:

Relatório de erros -
ORA-30554: o índice baseado na função A9778985.IDX_PARTICIPA_MINUTOSJOGADOS está desativado
30554. 00000 -  "function-based index %s.%s is disabled"
*Cause:    An attempt was made to access a function-based index that has
			  been marked disabled because the function on which the index
			  depends has been changed.
*Action:   Perform one of the following actions
			  -- drop the specified index using the DROP INDEX command
			  -- rebuild the specified index using the ALTER INDEX REBUILD command
			  -- enable the specified index using the ALTER INDEX ENABLE command
			  -- make the specified index usable using the ALTER INDEX UNUSABLE
			  command
*/
ALTER INDEX IDX_PARTICIPA_MINUTOSJOGADOS ENABLE;


-- Tornando o índice invisível
ALTER INDEX IDX_PARTICIPA_MINUTOSJOGADOS INVISIBLE;
EXPLAIN PLAN FOR SELECT * FROM PARTICIPA WHERE (HORASAIDA-HORAENTRADA)*24*60 >= &MINUTOS;
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/* A consulta é executada, sem utilizar o índice. */
ALTER INDEX IDX_PARTICIPA_MINUTOSJOGADOS VISIBLE;

-- Tornando o índice inutilizável (UNUSABLE)
ALTER INDEX IDX_JOGO_TIME1_PK UNUSABLE;
EXPLAIN PLAN FOR SELECT NUMERO, TIME1, TIME2 FROM JOGO WHERE TIME1 = '&TIME' OR TIME2 = '&TIME';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/* A consulta é executada, mas o índice não é utilizado. */

-- Reconstruindo o índice
ALTER INDEX IDX_JOGO_TIME1_PK REBUILD;
EXPLAIN PLAN FOR SELECT NUMERO, TIME1, TIME2 FROM JOGO WHERE TIME1 = '&TIME' OR TIME2 = '&TIME';
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/* A consulta é executada, utilizando o índice reconstruído. */

-- Renomeando o índice
ALTER INDEX IDX_PARTICIPA_MINUTOSJOGADOS RENAME TO IDX_PARTICIPA_MINUTOS;
EXPLAIN PLAN FOR SELECT * FROM PARTICIPA WHERE (HORASAIDA-HORAENTRADA)*24*60 >= &MINUTOS;
SELECT plan_table_output FROM TABLE (dbms_xplan.display());
/*
Índice renomeado, como pode ser visto no plano de consulta.

-----------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name                  | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |                       |     2 |    72 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| PARTICIPA             |     2 |    72 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN          | IDX_PARTICIPA_MINUTOS |     1 |       |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

	2 - access(("HORASAIDA"-"HORAENTRADA")*24*60>=60)
*/
