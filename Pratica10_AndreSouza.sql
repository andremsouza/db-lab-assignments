/*
	Nome: André Moreira Souza    N°USP: 9778985
	Prática 10 - PL/SQL - Pacotes
*/

-- Exercício 1 --------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE PKG_SCOREBOARD AS

	-- Registro para tuplas do scoreboard
	TYPE T_SCORE IS RECORD (
		TIME A9778985.TIME.PAIS%TYPE,
		PT NUMBER(2, 0), -- Pontuacao
		J NUMBER(2, 0), -- Número de jogos
		V NUMBER(2, 0), -- Número de vitórias
		E NUMBER(2, 0), -- Número de empates
		D NUMBER(2, 0), -- Número de derrotas
		GP NUMBER(2, 0), -- Número de gols a favor
		GC NUMBER(2, 0), -- Número de gols contra (do time adversário)
		SG NUMBER(2, 0) -- Saldo de gols (GP-GC)
	);
	-- Registro para armazenar resultados do scoreboard
	TYPE T_SCOREBOARD IS TABLE OF T_SCORE INDEX BY PLS_INTEGER;
	-- Procedimento para buscar e retornar o scoreboard de um grupo
	PROCEDURE get_scoreboard(p_grupo IN TIME.GRUPO%TYPE, p_scoreboard OUT T_SCOREBOARD);
	-- Procedimento para buscar e retornar o scoreboard de todos os grupos
	PROCEDURE get_scoreboard(p_scoreboard OUT);
	-- Exceção semântica (sem times na base de dados, ou grupo)
	e_noteams EXCEPTION;

END PKG_SCOREBOARD;

/

CREATE OR REPLACE PACKAGE BODY PKG_SCOREBOARD AS

	PROCEDURE get_scoreboard_group(p_grupo IN TIME.GRUPO%TYPE, p_scoreboard OUT T_SCOREBOARD) AS
	v_scoreboard T_SCOREBOARD;
	BEGIN

	EXCEPTION
		WHEN SUBSCRIPT_BEYOND_COUNT THEN DBMS_OUTPUT.PUT_LINE('Acesso indevido à uma coleção (elemento fora dos limites).'); ROLLBACK;
		WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Tentativa de acesso a elemento sem atribuição'); ROLLBACK;
		WHEN VALUE_ERROR THEN DBMS_OUTPUT.PUT_LINE('Tentativa de acesso a um elemento fora do intervalo do tipo de dados PLS_INTEGER.'); ROLLBACK;
		WHEN e_noteams THEN DBMS_OUTPUT.PUT_LINE('Não existem times na base de dados.'); ROLLBACK;
		WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('ERRO NRO: ' || SQLCODE || '; MENSAGEM: ' || SQLERRM); ROLLBACK;
	END;

END PKG_SCOREBOARD;

SELECT TIME.PAIS TIME, TIME.PONTUACAO PT, COUNT(JOGO.NUMERO) J,
	COUNT(CASE WHEN (TIME.PAIS = JOGO.TIME1 AND JOGO.NGOLS1 > JOGO.NGOLS2) OR (TIME.PAIS = JOGO.TIME2 AND JOGO.NGOLS2 > JOGO.NGOLS1) THEN 1 ELSE NULL END) V,
	COUNT(CASE WHEN (JOGO.NGOLS1 = JOGO.NGOLS2) THEN 1 ELSE NULL END) E,
	COUNT(CASE WHEN (TIME.PAIS = JOGO.TIME1 AND JOGO.NGOLS1 < JOGO.NGOLS2) OR (TIME.PAIS = JOGO.TIME2 AND JOGO.NGOLS2 < JOGO.NGOLS1) THEN 1 ELSE NULL END) D,
	SUM(CASE WHEN TIME.PAIS = JOGO.TIME1 THEN JOGO.NGOLS1 ELSE JOGO.NGOLS2 END) GP,
	SUM(CASE WHEN TIME.PAIS = JOGO.TIME1 THEN JOGO.NGOLS2 ELSE JOGO.NGOLS1 END) GC,
	SUM(CASE WHEN TIME.PAIS = JOGO.TIME1 THEN JOGO.NGOLS1-JOGO.NGOLS2 ELSE JOGO.NGOLS2-JOGO.NGOLS1 END) SG
	FROM TIME TIME
	INNER JOIN JOGO JOGO ON TIME.PAIS = JOGO.TIME1 OR TIME.PAIS = JOGO.TIME2
   	WHERE TIME.GRUPO = p_grupo
	AND JOGO.FASE = 'Primeira Fase'
	GROUP BY TIME.PAIS, TIME.PONTUACAO
	ORDER BY PT DESC, SG DESC, DBMS_RANDOM.VALUE DESC;