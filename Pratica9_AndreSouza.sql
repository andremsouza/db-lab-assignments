/*
	Nome: André Moreira Souza    N°USP: 9778985
	Prática 8 - PL/SQL - Coleções
*/

-- Exercício 1 --------------------------------------------------------------------------------------------------------

/*
	a) São necessários os privilégios CREATE PROCEDURE, ALTER PROCEDURE, DROP PROCEDURE, ou EXECUTE PROCEDURE, para objetos do próprio esquema do usuário. Esses privilégios são todos de sistema.

	b) Para isto, é necessário o privilégio de objeto EXECUTE PROCEDURE. Além disso, pode ser definido que o usuário que executa a procedure em questão precise dos privilégios utilizados durante a execução desta (e.g. alteração de uma tabela durante a procedure)
*/

-- Exercício 2 --------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE insert_jogo (
	p_numero IN jogo.numero%TYPE,
	p_fase IN jogo.fase%TYPE,
	p_time1 IN jogo.time1%TYPE,
	p_time2 IN jogo.time2%TYPE,
	p_datahora IN jogo.datahora%TYPE,
	p_ngols1 IN jogo.ngols1%TYPE,
	p_ngols2 IN jogo.ngols2%TYPE,
	p_estadio IN jogo.estadio%TYPE,
	p_arbitro IN jogo.arbitro%TYPE,
	p_assistente1 IN jogo.assistente1%TYPE,
	p_assistente2 IN jogo.assistente2%TYPE,
	p_quartoarbitro IN jogo.quartoarbitro%TYPE
) IS
	BEGIN
		INSERT INTO JOGO VALUES (p_numero, p_fase, p_time1, p_time2, p_datahora, p_ngols1, p_ngols2, p_estadio, p_arbitro, p_assistente1, p_assistente2, p_quartoarbitro);
	END;

SELECT * FROM JOGO;

EXECUTE insert_jogo(6666, 'Primeira Fase', 'Brasil', 'Holanda', TO_DATE('27/06/2022', 'dd/mm/yyyy'), 0, 0, 'Estadio Soccer City', 'A', 'B', 'C', 'D');
ROLLBACK;