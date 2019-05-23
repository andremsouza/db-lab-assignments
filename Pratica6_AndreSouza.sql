/*
	Nome: André Moreira Souza    N°USP: 9778985
	Prática 6 - Views
*/

-- Exercício 1 --------------------------------------------------------------------------------------------------------
/*
	Este exercício foi feito em trio, com os seguintes alunos:
	USER3 - André Moreira Souza - 9778985
	USER2 - Mateus Castilho Leite - 9771550
	USER1 - Vinicius Henrique Borges - 9771546
*/

-- Exercício 1a -------------------------------------------------------------------------------------------------------
-- USER1 dá privilégios na tabela seguranca para USER2
-- Necessário, caso a view posteriormente criada seja atualizável, para cascatear comandos INSERT, UPDATE e DELETE.
GRANT SELECT, INSERT, UPDATE, DELETE ON Seguranca TO M9771550 WITH GRANT OPTION; -- USER1

-- USER2 cria a view sobre a tabela seguranca, filtrando apenas alguns dados de segurancas cujo turno = 'Noite'
create or replace view  view_seguranca_noturno
	as select ncadastro, nome, funcao, turno
		from V9771546.seguranca
		where turno = 'Noite'; -- USER2

-- USER2 dá privilégios de leitura na view criada para USER3
GRANT SELECT ON view_seguranca_noturno TO A9778985; -- USER2

/*
	As permissões necessárias foram dadas e a view em questão foi criada.
*/

-- Exercício 1b -------------------------------------------------------------------------------------------------------
SELECT * FROM M9771550.view_seguranca_noturno; --USER2
INSERT INTO M9771550.view_seguranca_noturno VALUES (6666, 'Jailson Mendes', 'Seguranca Passiva', 'Noite'); --USER2
COMMIT; --USER2
UPDATE M9771550.view_seguranca_noturno SET funcao = 'Pai de família' WHERE ncadastro = 6666; --USER2
COMMIT; --USER2
DELETE FROM M9771550.view_seguranca_noturno WHERE ncadastro = 6666; --USER2
COMMIT; --USER2
/*
	O USER2 conseguiu realizar todas as operações com sucesso. As inserções, atualizações, deleções puderam ser observadas pelos demais usuários após o COMMIT;
*/


SELECT * FROM M9771550.view_seguranca_noturno; --USER3
INSERT INTO M9771550.view_seguranca_noturno VALUES (6666, 'Jailson Mendes', 'Seguranca Passiva', 'Noite'); --USER3
UPDATE M9771550.view_seguranca_noturno SET funcao = 'Pai de família' WHERE ncadastro = 6666; --USER3
DELETE FROM M9771550.view_seguranca_noturno WHERE ncadastro = 6666; --USER3

/*
	O USER3 conseguiu executar apenas o comando SELECT, que funcionou como esperado. Para os demais comandos, o seguinte erro foi reportado, pois o USER1 não tinha privilégios suficientes sobre a VIEW:

	Erro de SQL: ORA-01031: privilégios insuficientes
	01031. 00000 -  "insufficient privileges"
	*Cause:    An attempt was made to perform a database operation without
			   the necessary privileges.
	*Action:   Ask your database administrator or designated security
			   administrator to grant you the necessary privileges
*/

-- Exercício 1c -------------------------------------------------------------------------------------------------------
INSERT INTO M9771550.view_seguranca_noturno VALUES (6655, 'Fernando Rocha', 'Seguranca das claras', 'Manha'); --USER2
COMMIT; --USER2
SELECT * FROM M9771550.view_seguranca_noturno; --USER2
UPDATE M9771550.view_seguranca_noturno SET turno = 'Tarde' WHERE ncadastro = 5; --USER2
COMMIT; --USER2
SELECT * FROM M9771550.view_seguranca_noturno; --USER2


/*
	As tuplas inseridas / atualizadas não apareceram nas subsequentes consultas na VIEW, devido às constraints de seleção utilizadas.
	Após o comando COMMIT, as mudanças efetuadas puderam ser observadas na tabela mestre.
*/


-- Exercício 1d -------------------------------------------------------------------------------------------------------
create or replace view  view_seguranca_noturno
	as select ncadastro, nome, funcao, turno
		from V9771546.seguranca
		where turno = 'Noite'
		with check option; -- USER2

INSERT INTO M9771550.view_seguranca_noturno VALUES (6665, 'Fernando Rocha', 'Seguranca das claras', 'Manha'); --USER2
COMMIT; --USER2
SELECT * FROM M9771550.view_seguranca_noturno; --USER2
UPDATE M9771550.view_seguranca_noturno SET turno = 'Tarde' WHERE ncadastro = 6666; --USER2
COMMIT; --USER2
SELECT * FROM M9771550.view_seguranca_noturno; --USER2

/*
	Tanto a inserção como a atualização não funcionaram, pois violavam as condições de seleção. O seguinte erro foi reportado para estas operações:

	Relatório de erros -
	ORA-01402: violação da cláusula where da view WITH CHECK OPTION
*/

-- Exercício 1e -------------------------------------------------------------------------------------------------------
REVOKE SELECT, INSERT, UPDATE, DELETE ON seguranca FROM M9771550; --USER1

SELECT * FROM M9771550.view_seguranca_noturno; --USER3
SELECT * FROM M9771550.view_seguranca_noturno; --USER2
INSERT INTO M9771550.view_seguranca_noturno VALUES (6666, 'Jailson Mendes', 'Seguranca Passiva', 'Noite'); --USER2
UPDATE M9771550.view_seguranca_noturno SET funcao = 'Pai de família' WHERE ncadastro = 6666; --USER2
DELETE FROM M9771550.view_seguranca_noturno WHERE ncadastro = 6666; --USER2

/*
	Para todas as operações executadas pelos USER2 e USER3, ocorreram erros devido à revogação das permissões. O seguinte erro foi reportado:
	Relatório de erros -
	Erro de SQL: ORA-04063: view "M9771550.VIEW_SEGURANCA_NOTURNO" contém erros
	04063. 00000 -  "%s has errors"
	*Cause:    Attempt to execute a stored procedure or use a view that has
			   errors.  For stored procedures, the problem could be syntax errors
			   or references to other, non-existent procedures.  For views,
			   the problem could be a reference in the view's defining query to
			   a non-existent table.
			   Can also be a table which has references to non-existent or
			   inaccessible types.
	*Action:   Fix the errors and/or create referenced objects as necessary.
*/

-- Exercício 2 --------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW view_jogador (NFIFA, NOME, POSICAO, TIME, CAPITAO, TECNICO) AS
	SELECT J.NFIFA, J.NOME, J.POSICAO, J.TIME, J.CAPITAO, T.TECNICO FROM JOGADOR J
		INNER JOIN TIME T ON J.TIME = T.PAIS;

-- Exercício 2a -------------------------------------------------------------------------------------------------------
/*
	Relembrando o conceito de preservação de chave: "Uma tupla de uma tabela com preservação de chave tem no máximo uma correspondência para uma determinada visão."
	Para esta visão, apenas as colunas provenientes da tabela JOGADOR são atualizáveis, devido à preservação de chave. Intuivamente, é possível notar que cada jogador aparece apenas uma vez na visão. No entanto, a coluna TECNICO, correspondente à tupla da tabela TIME referenciada pela tabela JOGADOR, tem múltiplas correspondências na visão (uma para cada jogador pertencente a um determinado time).
	Sendo assim, para a view_jogador, operações de UPDATE, INSERT, DELETE só poderão ser efetuadas sobre colunas provenientes da table jogador (NFIFA, NOME, POSICAO, TIME, CAPITAO), e seus efeitos serão cascateados para a tabela JOGADOR.
*/

-- Exercício 2b -------------------------------------------------------------------------------------------------------
/*
	Testando UPDATE, tentarei atualizar colunas provenientes das duas tabelas
*/
-- Com violação de chave estrangeira.
UPDATE VIEW_JOGADOR SET TIME = 'Tabajara' WHERE NFIFA = 84;
/*
	As restrições de integridade também são aplicáveis às views. Como essa atualização violaria a chave estrangeira, o seguinte erro foi reportado:
	
	ORA-02291: restrição de integridade (A9778985.FK_JOGADOR) violada - chave mãe não localizada
*/

-- Com colunas provenientes da tabela JOGADOR
UPDATE VIEW_JOGADOR SET NFIFA = 46, NOME = 'Daniel Alves Alves', POSICAO = 'Zagueiro', Time = 'Espanha', CAPITAO = 'S' WHERE NFIFA = 46;
SELECT * FROM VIEW_JOGADOR WHERE NFIFA = 46;
SELECT * FROM JOGADOR J WHERE J.NFIFA = 46;
ROLLBACK; -- Para retornar a base de dados ao seu estado original.
/*
	Saída das consultas:
		 NFIFA  NOME                POSICAO     TIME    CAPITAO TECNICO
		 46     Daniel Alves Alves  Zagueiro    Espanha S       Vicente del Bosque

		 NFIFA  NOME                APELIDO         DTANASC     POSICAO     CAPITAO TIME
		 46     Daniel Alves Alves  Daniel Alves    06/05/83    Zagueiro    S       Espanha

	A atualização foi efetuada com sucesso, e o resultado foi refletido nas seleções sobre a tabela mestre e a própria visão.
*/

-- Com colunas provenientes da table TIME
UPDATE VIEW_JOGADOR SET TECNICO = 'Dunga' WHERE Time = 'Brasil';
/*
	Como a tabela time não tem preservação de chave para esta view, o seguinte erro foi reportado:
	
	Erro de SQL: ORA-01779: não é possível modificar uma coluna que mapeie uma tabela não preservada pela chave
	01779. 00000 -  "cannot modify a column which maps to a non key-preserved table"
	*Cause:    An attempt was made to insert or update columns of a join view which
			   map to a non-key-preserved table.
	*Action:   Modify the underlying base tables directly.
*/

/*
	Testando INSERT e DELETE
*/
-- Com todas as colunas
INSERT INTO VIEW_JOGADOR (NFIFA, NOME, POSICAO, TIME, CAPITAO, TECNICO) VALUES (4242, 'Jeff Michael', 'Atacante', 'Estados Unidos', 'N', 'Dunga');
/*
	Como tentamos inserir colunas correspondentes à tabela TIME, que não possui preservação de chave, o seguinte erro foi reportado:
	
	Erro de SQL: ORA-01776: não é possível modificar mais de uma vez uma tabela de base através da view de junção
	01776. 00000 -  "cannot modify more than one base table through a join view"
	*Cause:    Columns belonging to more than one underlying table were either
			   inserted into or updated.
	*Action:   Phrase the statement as two or more separate statements.
*/

-- Com colunas apenas da tabela JOGADOR
INSERT INTO VIEW_JOGADOR (NFIFA, NOME, POSICAO, TIME, CAPITAO) VALUES (4242, 'Jeff Michael', 'Atacante', 'Estados Unidos', 'N');
SELECT * FROM VIEW_JOGADOR WHERE NFIFA=4242;
SELECT * FROM JOGADOR WHERE NFIFA=4242;
COMMIT; -- Resultado será utilizado para testar o comando DELETE.
/*
	Saída das consultas:
		NFIFA   NOME            POSICAO     TIME            CAPITAO TECNICO
		4242	Jeff Michael	Atacante	Estados Unidos	N	    Bob Bradley
		
		NFIFA   NOME            APELIDO DTANASC POSICAO     CAPITAO TIME
		4242	Jeff Michael	(null)	(null)	Atacante	N	    Estados Unidos
		
	A inserção foi feita com sucesso, e o resultado foi refletido na visão e na tabela mestre. Podemos notar que apenas as colunas presentes na visão tiveram valores atribuídos, e as demais colunas da tabela mestre ficaram nulas.
*/

-- DELETE da tupla inserida
DELETE FROM VIEW_JOGADOR WHERE NFIFA=4242;
COMMIT;
/*
	Saída:
		1 linha excluído.
	A remoção foi feita com sucesso, sobre a tupla da tabela mestre "JOGADOR".
*/
-- DELETE de várias tuplas, filtrando pelo nome do técnico
DELETE FROM VIEW_JOGADOR WHERE TECNICO='Carlos Alberto Parreira';
ROLLBACK;
/*
	Saída:
		43 linhas excluído.
	A remoção foi feita com sucesso. Todas as tuplas filtradas foram removidas da tabela mestre "JOGADOR".
*/

-- Exercício 2c -------------------------------------------------------------------------------------------------------
/*
	Sim. A coluna TIME da visão seria não atualizável, se referenciasse a tabela TIME. Isso aconteceria devido à preservação de chave, pois cada tupla da tabela TIME (PAIS, TECNICO) seria referenciada múltiplas vezes na visão (para cada jogador de um determinado time).
	Logo, as colunas atualizáveis da visão modificada seriam (NFIFA, NOME, POSICAO, CAPITAO). Além disso, como existe a constraint NOT NULL para a JOGADOR.TIME, não seria possível fazer inserções na visão, pois tais não atribuiriam um valor para a coluna JOGADOR.TIME.
	
	Já fizemos os testes com a coluna TIME referenciando a tabela JOGADOR. A seguir, será recriada a visão referenciando a tabela TIME, e novos testes serão feitos.
*/
CREATE OR REPLACE VIEW view_jogador (NFIFA, NOME, POSICAO, TIME, CAPITAO, TECNICO) AS
	SELECT J.NFIFA, J.NOME, J.POSICAO, T.PAIS, J.CAPITAO, T.TECNICO FROM JOGADOR J
		INNER JOIN TIME T ON J.TIME = T.PAIS;

/*
	Testando UPDATE, tentarei atualizar colunas provenientes das duas tabelas
*/
-- Com violação de chave estrangeira.
UPDATE VIEW_JOGADOR SET TIME = 'Tabajara' WHERE NFIFA = 84;
/*
	Notemos que a verificação de preservação de chave tem precedência sobre a verificação de restrições de integridade. O seguinte erro foi reportado:
	
	Erro de SQL: ORA-01779: não é possível modificar uma coluna que mapeie uma tabela não preservada pela chave
	01779. 00000 -  "cannot modify a column which maps to a non key-preserved table"
	*Cause:    An attempt was made to insert or update columns of a join view which
			   map to a non-key-preserved table.
	*Action:   Modify the underlying base tables directly.
*/

-- Com colunas provenientes da tabela JOGADOR
UPDATE VIEW_JOGADOR SET NFIFA = 46, NOME = 'Daniel Alves Alves', POSICAO = 'Zagueiro', CAPITAO = 'S' WHERE NFIFA = 46;
SELECT * FROM VIEW_JOGADOR WHERE NFIFA = 46;
SELECT * FROM JOGADOR J WHERE J.NFIFA = 46;
ROLLBACK; -- Para retornar a base de dados ao seu estado original.
/*
	Saída das consultas:
		 NFIFA  NOME                POSICAO     TIME    CAPITAO TECNICO
		 46     Daniel Alves Alves  Zagueiro    Brasil  S       Vicente del Bosque

		 NFIFA  NOME                APELIDO         DTANASC     POSICAO     CAPITAO TIME
		 46     Daniel Alves Alves  Daniel Alves    06/05/83    Zagueiro    S       Brasil

	A atualização foi efetuada com sucesso, e o resultado foi refletido nas seleções sobre a tabela mestre e a própria visão.
*/

-- Com colunas provenientes da table TIME
UPDATE VIEW_JOGADOR SET TECNICO = 'Dunga' WHERE Time = 'Brasil';
/*
	Assim como nos testes anteriores, não é possível atualizar valores de tabelas sem preservação de chave.
	
	Erro de SQL: ORA-01779: não é possível modificar uma coluna que mapeie uma tabela não preservada pela chave
	01779. 00000 -  "cannot modify a column which maps to a non key-preserved table"
	*Cause:    An attempt was made to insert or update columns of a join view which
			   map to a non-key-preserved table.
	*Action:   Modify the underlying base tables directly.
*/

/*
	Testando INSERT e DELETE
*/
-- Com todas as colunas
INSERT INTO VIEW_JOGADOR (NFIFA, NOME, POSICAO, TIME, CAPITAO, TECNICO) VALUES (4242, 'Jeff Michael', 'Atacante', 'Estados Unidos', 'N', 'Dunga');
/*
	Como tentamos inserir colunas correspondentes à tabela TIME, que não possui preservação de chave, o seguinte erro foi reportado:
	
	Erro de SQL: ORA-01776: não é possível modificar mais de uma vez uma tabela de base através da view de junção
	01776. 00000 -  "cannot modify more than one base table through a join view"
	*Cause:    Columns belonging to more than one underlying table were either
			   inserted into or updated.
	*Action:   Phrase the statement as two or more separate statements.
*/

-- Com colunas apenas da tabela JOGADOR
INSERT INTO VIEW_JOGADOR (NFIFA, NOME, POSICAO, CAPITAO) VALUES (4242, 'Jeff Michael', 'Atacante', 'N');
/*
	Devido à restrição NOT NULL sobre a coluna TIME, foi reportado o seguinte erro:
	
	ORA-01400: não é possível inserir NULL em ("A9778985"."JOGADOR"."TIME")
*/

-- DELETE de várias tuplas, filtrando pelo nome do técnico
DELETE FROM VIEW_JOGADOR WHERE TECNICO='Carlos Alberto Parreira';
ROLLBACK;
/*
	Saída:
		43 linhas excluído.
	A remoção foi feita com sucesso. Todas as tuplas filtradas foram removidas da tabela mestre "JOGADOR".
*/

-- Exercício 2d -------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW view_jogador (NFIFA, NOME, POSICAO, TIME, CAPITAO, TECNICO) AS
	SELECT J.NFIFA, J.NOME, J.POSICAO, J.TIME, J.CAPITAO, T.TECNICO FROM JOGADOR J
		INNER JOIN TIME T ON J.TIME = T.PAIS
		WITH CHECK OPTION;

/*
	Neste caso, não haverá nenhuma mudança sobre as operações, pois não existem filtragems pela cláusula WHERE, na criação da visão.
*/

-- Exercício 3a -------------------------------------------------------------------------------------------------------
/*
	Criando uma visão agregando dados da tabela PARTICIPA, agrupando por jogo.
	Segundo o Oracle Warehousing Guide, para poder utilizar o fast refresh, é necessário criar o view log e, na lista de colunas da visão, devem haver contagens das colunas agregadas.
	Citando: "[...] For fast refresh to be possible, the SELECT list must contain all of the GROUP BY columns (if present), and there must be a COUNT(*) and a COUNT(column) on any aggregated columns. Also, materialized view logs must be present on all tables referenced in the query that defines the materialized view.[...]" 
*/



-- criando view log para poder utilizar o método FAST REFRESH
CREATE MATERIALIZED VIEW LOG ON PARTICIPA WITH SEQUENCE, ROWID
	(JOGO, NCARTAOAM, NCARTAOVERM, NFALTAS, NPENALTES, NGOLS)
	INCLUDING NEW VALUES;

-- criando a visão materializada
CREATE MATERIALIZED VIEW view_participa_agg
	BUILD IMMEDIATE -- construir imediatamente após criação
	REFRESH FAST ON COMMIT -- refazer visão após commit, utilizando o método "FAST"
	AS
		SELECT P.JOGO, SUM(P.NCARTAOAM) TOTALCARTOESAM, SUM(P.NCARTAOVERM) TOTALCARTOESVERM, SUM(P.NFALTAS) TOTALFALTAS, 
			SUM(P.NPENALTES) TOTALPENALTIES, SUM(P.NGOLS) TOTALGOLS, COUNT(*) AS CNTPARTICIPA, COUNT(P.NCARTAOAM) CNTCARTOESAM,
			COUNT(P.NCARTAOVERM) CNTCARTOESVERM, COUNT(P.NFALTAS) CNTNFALTAS, COUNT(P.NPENALTES) CNTNPENALTES, COUNT(P.NGOLS) CNTNGOLS
		FROM PARTICIPA P
		GROUP BY P.JOGO;

/*
	A visão foi criada com sucesso.
*/

-- Exercício 3b --------------------------------------------------------------------------------------------------------
/*
	1) Existem dois métodos para popular uma visão materialiada, ambos definidos durante a criação da mesma: BUILD IMMEDIATE e BUILD DEFERRED.
		BUILD IMMEDIATE: A visão é populada imediatamente após sua criação (opção padrão);
		BUILD DEFERRED: A definição da visão é criada, mas esta não é populada imediatamente após a criação, e sim na próxima operação de REFRESH.
	
	2) Segundo o Oracle Data Warehousing Guide, existem quatro opções para o REFRESH:
		COMPLETE: Reeexecuta a consulta que define a visão;
		FAST: Aplica mudanças incrementais utilizando a informação dos materialized view logs;
		FORCE: Utiliza o método FAST, se possível, e o método COMPLETE, caso contrário;
		NEVER: Não haverá REFRESH com os mecanismos do SGBD.
		
	3) Existem dois modos que definem quando o REFRESH é realizado:
		ON COMMIT: O refresh ocorre após qualquer comando COMMIT. Só pode ser utilizado quando a visão materializada é "fast refreshable";
		ON DEMAND: O refresh ocorre manualmente, executado pelo usuário.
*/

-- Exercício 3c -------------------------------------------------------------------------------------------------------

/*
	A visão será atualizada, utilizando o método FAST REFRESH, a cada 24 horas. Este período é realista para esta aplicação, visto que deseja-se que os dados sobre os jogos estejam atualizados rapidamente.
*/

CREATE MATERIALIZED VIEW view_participa_agg_days
	BUILD IMMEDIATE -- construir imediatamente após criação
	REFRESH FAST -- Utilizar FAST REFRESH
	NEXT TRUNC(SYSDATE + 1) -- Fazer REFRESH em cada 24 horas.
	AS
		SELECT P.JOGO, SUM(P.NCARTAOAM) TOTALCARTOESAM, SUM(P.NCARTAOVERM) TOTALCARTOESVERM, SUM(P.NFALTAS) TOTALFALTAS, 
			SUM(P.NPENALTES) TOTALPENALTIES, SUM(P.NGOLS) TOTALGOLS, COUNT(*) AS CNTPARTICIPA, COUNT(P.NCARTAOAM) CNTCARTOESAM,
			COUNT(P.NCARTAOVERM) CNTCARTOESVERM, COUNT(P.NFALTAS) CNTNFALTAS, COUNT(P.NPENALTES) CNTNPENALTES, COUNT(P.NGOLS) CNTNGOLS
		FROM PARTICIPA P
		GROUP BY P.JOGO;

/*
	Durante a criação, ocorreu um erro que eu não pude resolver, o que achei estranho, pois apenas mudei a cláusula do período de REFRESH.
	O seguinte erro foi reportado:
	
	Relatório de erros -
	ORA-00604: ocorreu um erro no nível 1 SQL recursivo
	ORA-00923: palavra-chave FROM não localizada onde esperada
	00604. 00000 -  "error occurred at recursive SQL level %s"
	*Cause:    An error occurred while processing a recursive SQL statement
			   (a statement applying to internal dictionary tables).
	*Action:   If the situation described in the next error on the stack
			   can be corrected, do so; otherwise contact Oracle Support.

*/