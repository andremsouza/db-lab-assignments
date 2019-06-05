/*
	Nome: André Moreira Souza    N°USP: 9778985
	Prática 10 - PL/SQL - Pacotes
*/

-- Exercício 1 ----------------------------------------------------------------

CREATE OR REPLACE PACKAGE PKG_SCOREBOARD AS

	-- Registro para tuplas do scoreboard
	TYPE T_SCORE IS RECORD (
		TIME A9778985.TIME.PAIS%TYPE,
		PT NUMBER(2, 0), -- Pontuação
		J NUMBER(2, 0), -- Número de jogos
		V NUMBER(2, 0), -- Número de vitórias
		E NUMBER(2, 0), -- Número de empates
		D NUMBER(2, 0), -- Número de derrotas
		GP NUMBER(2, 0), -- Número de gols a favor
		GC NUMBER(2, 0), -- Número de gols contra (do time adversário)
		SG NUMBER(2, 0) -- Saldo de gols (GP-GC)
	);
	-- Coleção para armazenar resultados do scoreboard
	TYPE T_SCOREBOARD IS TABLE OF T_SCORE INDEX BY PLS_INTEGER;
	-- Procedimento para buscar e retornar o scoreboard de um grupo
	PROCEDURE get_scoreboard(p_grupo IN TIME.GRUPO%TYPE,
							p_scoreboard OUT T_SCOREBOARD);
	-- Procedimento para buscar e retornar o scoreboard de todos os grupos
	PROCEDURE get_scoreboard(p_scoreboard OUT T_SCOREBOARD);
	-- Exceção semântica (sem times na base de dados, ou grupo)
	e_noteams EXCEPTION;

END PKG_SCOREBOARD;

/

CREATE OR REPLACE PACKAGE BODY PKG_SCOREBOARD AS

	PROCEDURE get_scoreboard(p_grupo IN TIME.GRUPO%TYPE, 
							p_scoreboard OUT T_SCOREBOARD) AS
	/*
		Procedimento que retorna em p_scoreboard a tabela de classificação dos
		times de um determinado grupo p_grupo, levando em conta os jogos da
		primeira fase.
	*/
	BEGIN
		-- Realizando consulta e atribuindo à coleção
		SELECT TIME.PAIS TIME, TIME.PONTUACAO PT, COUNT(JOGO.NUMERO) J,
			COUNT(
				CASE WHEN (TIME.PAIS = JOGO.TIME1 AND JOGO.NGOLS1 > JOGO.NGOLS2)
					OR (TIME.PAIS = JOGO.TIME2 AND JOGO.NGOLS2 > JOGO.NGOLS1)
					THEN 1 ELSE NULL END
			) V,
			COUNT(
				CASE WHEN (JOGO.NGOLS1 = JOGO.NGOLS2) THEN 1 ELSE NULL END
			) E,
			COUNT(
				CASE WHEN (TIME.PAIS = JOGO.TIME1 AND JOGO.NGOLS1 < JOGO.NGOLS2)
					OR (TIME.PAIS = JOGO.TIME2 AND JOGO.NGOLS2 < JOGO.NGOLS1)
					THEN 1 ELSE NULL END
			) D,
			SUM(
				CASE WHEN TIME.PAIS = JOGO.TIME1 THEN JOGO.NGOLS1
					ELSE JOGO.NGOLS2 END
			) GP,
			SUM(
				CASE WHEN TIME.PAIS = JOGO.TIME1 THEN JOGO.NGOLS2 
					ELSE JOGO.NGOLS1 END
			) GC,
			SUM(
				CASE WHEN TIME.PAIS = JOGO.TIME1 THEN JOGO.NGOLS1-JOGO.NGOLS2
					ELSE JOGO.NGOLS2-JOGO.NGOLS1 END
			) SG
			BULK COLLECT INTO p_scoreboard -- bulk collect para a coleção
			FROM TIME TIME
			INNER JOIN JOGO JOGO ON 
				TIME.PAIS = JOGO.TIME1 OR TIME.PAIS = JOGO.TIME2
			WHERE TIME.GRUPO = p_grupo -- Filtrando por grupo
				AND JOGO.FASE = 'Primeira Fase'
			GROUP BY TIME.PAIS, TIME.PONTUACAO
			ORDER BY PT DESC, SG DESC, DBMS_RANDOM.VALUE DESC;
		-- Erro semântico se a consulta não retornar tuplas
		IF p_scoreboard.count = 0 THEN
			RAISE e_noteams;
		END IF;
		-- Esse procedimento não trata exceções.
		-- As exceções devem ser tratadas no programa PL/SQL ou na aplicação.
	END;

	PROCEDURE get_scoreboard(p_scoreboard OUT T_SCOREBOARD) AS
	/*
		Procedimento que retorna em p_scoreboard a tabela de classificação dos
		times de todos os grupos, levando em conta os jogos da primeira fase.
	*/
	BEGIN
		-- Realizando consulta e atribuindo à coleção
		SELECT TIME.PAIS TIME, TIME.PONTUACAO PT, COUNT(JOGO.NUMERO) J,
			COUNT(
				CASE WHEN (TIME.PAIS = JOGO.TIME1 AND JOGO.NGOLS1 > JOGO.NGOLS2)
					OR (TIME.PAIS = JOGO.TIME2 AND JOGO.NGOLS2 > JOGO.NGOLS1)
					THEN 1 ELSE NULL END
			) V,
			COUNT(
				CASE WHEN (JOGO.NGOLS1 = JOGO.NGOLS2) THEN 1 ELSE NULL END
			) E,
			COUNT(
				CASE WHEN (TIME.PAIS = JOGO.TIME1 AND JOGO.NGOLS1 < JOGO.NGOLS2)
					OR (TIME.PAIS = JOGO.TIME2 AND JOGO.NGOLS2 < JOGO.NGOLS1)
					THEN 1 ELSE NULL END
			) D,
			SUM(
				CASE WHEN TIME.PAIS = JOGO.TIME1 THEN JOGO.NGOLS1
					ELSE JOGO.NGOLS2 END
			) GP,
			SUM(
				CASE WHEN TIME.PAIS = JOGO.TIME1 THEN JOGO.NGOLS2 
					ELSE JOGO.NGOLS1 END
			) GC,
			SUM(
				CASE WHEN TIME.PAIS = JOGO.TIME1 THEN JOGO.NGOLS1-JOGO.NGOLS2
					ELSE JOGO.NGOLS2-JOGO.NGOLS1 END
			) SG
			BULK COLLECT INTO p_scoreboard -- bulk collect para a coleção
			FROM TIME TIME
			INNER JOIN JOGO JOGO ON 
				TIME.PAIS = JOGO.TIME1 OR TIME.PAIS = JOGO.TIME2
			WHERE JOGO.FASE = 'Primeira Fase'
			GROUP BY TIME.PAIS, TIME.PONTUACAO
			ORDER BY PT DESC, SG DESC, DBMS_RANDOM.VALUE DESC;
		-- Erro semântico se a consulta não retornar tuplas
		IF p_scoreboard.count = 0 THEN
			RAISE e_noteams;
		END IF;
		-- Esse procedimento não trata exceções.
		-- As exceções devem ser tratadas no programa PL/SQL ou na aplicação.
	END;

END PKG_SCOREBOARD;

/*
	Testando o funcionamento do pacote com um programa PL/SQL
*/
DECLARE
	-- Variáveis para retorno da procedure e seleção de parâmetros
	v_scoreboard1 PKG_SCOREBOARD.T_SCOREBOARD;
	v_grupo1 TIME.GRUPO%TYPE;
	v_scoreboard2 PKG_SCOREBOARD.T_SCOREBOARD;
	v_grupo2 TIME.GRUPO%TYPE;
	v_scoreboard3 PKG_SCOREBOARD.T_SCOREBOARD;
BEGIN
	-- Simulando chamada de procedimentos com grupos 'A' e 'B'
	v_grupo1 := 'A';
	v_grupo2 := 'B';

	-- Executando procedure e imprimindo resultados para v_grupo1
	EXEC PKG_SCOREBOARD.get_scoreboard(v_grupo1, v_scoreboard1)

	-- Imprimindo resultados para v_grupo1
	DBMS_OUTPUT.PUT_LINE('TIME' || chr(9) || 'PT' || chr(9) || 'J' || chr(9)
		|| 'V' || chr(9) || 'E' || chr(9) || 'D' || chr(9) || 'GP' || chr(9)
		|| 'GC' || chr(9) || 'SG');
	
	FOR i in v_scoreboard1.FIRST .. v_scoreboard1.LAST LOOP
		DBMS_OUTPUT.PUT_LINE(v_scoreboard1(i).TIME || chr(9) 
			|| v_scoreboard1(i).PT || chr(9) || v_scoreboard1(i).J || chr(9)
			|| v_scoreboard1(i).V || chr(9) || v_scoreboard1(i).E || chr(9)
			|| v_scoreboard1(i).D || chr(9) || v_scoreboard1(i).GP || chr(9)
			|| v_scoreboard1(i).GC || chr(9) || v_scoreboard1(i).SG);
	END LOOP;

	-- Executando procedure e imprimindo resultados para v_grupo2
	EXEC PKG_SCOREBOARD.get_scoreboard(v_grupo2, v_scoreboard2)

	-- Imprimindo resultados para v_grupo2
	DBMS_OUTPUT.PUT_LINE('TIME' || chr(9) || 'PT' || chr(9) || 'J' || chr(9)
		|| 'V' || chr(9) || 'E' || chr(9) || 'D' || chr(9) || 'GP' || chr(9)
		|| 'GC' || chr(9) || 'SG');
	
	FOR i in v_scoreboard2.FIRST .. v_scoreboard2.LAST LOOP
		DBMS_OUTPUT.PUT_LINE(v_scoreboard2(i).TIME || chr(9) 
			|| v_scoreboard2(i).PT || chr(9) || v_scoreboard2(i).J || chr(9)
			|| v_scoreboard2(i).V || chr(9) || v_scoreboard2(i).E || chr(9)
			|| v_scoreboard2(i).D || chr(9) || v_scoreboard2(i).GP || chr(9)
			|| v_scoreboard2(i).GC || chr(9) || v_scoreboard2(i).SG);
	END LOOP;

	-- Executando procedure e imprimindo resultados para todos os grupos
	EXEC PKG_SCOREBOARD.get_scoreboard(v_scoreboard3)

	-- Imprimindo resultados para todos os grupos
	DBMS_OUTPUT.PUT_LINE('TIME' || chr(9) || 'PT' || chr(9) || 'J' || chr(9)
		|| 'V' || chr(9) || 'E' || chr(9) || 'D' || chr(9) || 'GP' || chr(9)
		|| 'GC' || chr(9) || 'SG');
	
	FOR i in v_scoreboard3.FIRST .. v_scoreboard3.LAST LOOP
		DBMS_OUTPUT.PUT_LINE(v_scoreboard3(i).TIME || chr(9) 
			|| v_scoreboard3(i).PT || chr(9) || v_scoreboard3(i).J || chr(9)
			|| v_scoreboard3(i).V || chr(9) || v_scoreboard3(i).E || chr(9)
			|| v_scoreboard3(i).D || chr(9) || v_scoreboard3(i).GP || chr(9)
			|| v_scoreboard3(i).GC || chr(9) || v_scoreboard3(i).SG);
	END LOOP;

	-- Tratando exceções
	EXCEPTION
			WHEN SUBSCRIPT_BEYOND_COUNT THEN DBMS_OUTPUT.PUT_LINE(
				'Acesso indevido à uma coleção (elemento fora dos limites).');
			WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE(
				'Tentativa de acesso a elemento sem atribuição');
			WHEN VALUE_ERROR THEN DBMS_OUTPUT.PUT_LINE(
				'Tentativa de acesso a um elemento fora do intervalo do' || ' '
				|| 'tipo de dados PLS_INTEGER.');
			WHEN PKG_SCOREBOARD.e_noteams THEN DBMS_OUTPUT.PUT_LINE(
				'Não existem times na base de dados.');
			WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(
				'ERRO NRO: ' || SQLCODE || '; MENSAGEM: ' || SQLERRM);
END;