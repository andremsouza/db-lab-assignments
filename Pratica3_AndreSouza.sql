/*
Nome: André Moreira Souza    N°USP: 9778985
Prática 3 – SQL - DML
*/

-- Exercício 1:

-- Exercício 2a:

/*
	Criando uma tabela simples, com objetivo de testar a inserção de mútliplas tuplas a partir de um select
*/

CREATE TABLE OcorrenciaBrasil (
	Data DATE NOT NULL,
	Local VARCHAR2(100) NOT NULL,
	Equipe VARCHAR2(100) NOT NULL,
	Descricao VARCHAR(200) NOT NULL,
	CONSTRAINT PK_Ocorrencia_Brasil PRIMARY KEY (Data, Local, Equipe)
);

/*
	Inserindo tuplas nas tabelas Trabalha, OcorrenciaTrabalha;
*/

INSERT INTO Trabalha VALUES ('Seguranca nas Arquibancadas', 15, 'Padrão');
INSERT INTO Trabalha VALUES ('Seguranca nas Arquibancadas', 30, 'Padrão');
INSERT INTO Trabalha VALUES ('Seguranca dos Arbitros', 46, 'Padrão');
INSERT INTO OcorrenciaTrabalha VALUES ('Seguranca nas Arquibancadas', 15, 1, 'Briga entre torcedores do Brasil.');
INSERT INTO OcorrenciaTrabalha VALUES ('Seguranca nas Arquibancadas', 30, 1, 'Porte de items não autorizados entre torcedores do Brasil.');
INSERT INTO OcorrenciaTrabalha VALUES ('Seguranca dos Arbitros', 46, 4, 'Discussão entre jogadores e quarto árbitro.');

INSERT INTO OcorrenciaBrasil
	SELECT J.DataHora, J.Estadio || ', ' || E.Cidade, O.Equipe, O.Descricao FROM OcorrenciaTrabalha O
		INNER JOIN Jogo J ON O.Jogo = J.Numero
		INNER JOIN Estadio E ON J.Estadio = E.Nome
		WHERE UPPER(J.Time1) = 'BRASIL' OR UPPER(J.Time2) = 'BRASIL';

/*
	Resultado esperado para uma consulta de todas as tuplas em OcorrenciaBrasil:
	DATA     LOCAL                                                                                                EQUIPE                                                                                               DESCRICAO
-------- ---------------------------------------------------------------------------------------------------- ---------------------------------------------------------------------------------------------------- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
15/06/22 Estadio Ellis Park, Joanesburgo                                                                      Seguranca nas Arquibancadas                                                                          Briga entre torcedores do Brasil.
20/06/22 Estadio Soccer City, Joanesburgo                                                                     Seguranca nas Arquibancadas                                                                          Porte de items não autorizados entre torcedores do Brasil.
25/06/22 Estadio Moses Mabhida, Durban                                                                        Seguranca dos Arbitros                                                                               Discussão entre jogadores e quarto árbitro.

*/

-- Exercício 2b:

/*
    Inserindo dados na tabela Profissional, para testar resultados.
*/

INSERT INTO PROFISSIONAL VALUES (44, 'Zé da Silva', 'Comentarista');
INSERT INTO PROFISSIONAL VALUES (45, 'João da Silva', 'Comentarista');
INSERT INTO PROFISSIONAL VALUES (46, 'José da Silva', 'Comentarista');

DELETE FROM PROFISSIONAL P
    WHERE P.NFIFA NOT IN (SELECT E.NFIFAProfissional FROM EMPREGA E);

-- Exercício 2c:
SELECT J.NOME, J.NFIFA, J.TIME PAIS FROM JOGADOR J
    WHERE EXTRACT(YEAR FROM J.DTANASC) < 1980;

-- Exercício 2d:

/*
    Inserindo dados na tabela Treina, para testar resultados.
*/
INSERT INTO TREINA VALUES ('Mexico', 'Estadio Green Point', TO_DATE('14/04/2022', 'DD/MM/YYYY'));
INSERT INTO TREINA VALUES ('Mexico', 'Estadio Mbombela', TO_DATE('14/07/2022', 'DD/MM/YYYY'));

SELECT DISTINCT T.PAIS, T.NFIFA, E.NOME ESTADIO, E.CIDADE FROM TIME T
    INNER JOIN TREINA TR ON T.PAIS = TR.TIME
    INNER JOIN ESTADIO E ON TR.ESTADIO = E.NOME
    WHERE UPPER(T.GRUPO) = 'A' AND EXTRACT(MONTH FROM TR.DTATREINO) BETWEEN 4 AND 6;

/*
    Resultado deve incluir estádios Soccer City, Green Point e Ellis Park apenas.
*/

-- Exercício 2e:
/*
    "[...]Além disso, se ele participou de algum jogo como *titular*, inclua o número, data e a fase do jogo.[...]

    Utilizei distinct para que, nos casos em que um jogador participou de uma ou mais partidas como reserva ou não participou, a tupla resultante não se repita.
*/

SELECT DISTINCT JOGADOR.NOME, JOGADOR.NFIFA,
        CASE PART.ESCALACAO WHEN 'Titular' THEN JOGO.NUMERO ELSE NULL END JOGO,
        CASE PART.ESCALACAO WHEN 'Titular' THEN JOGO.DATAHORA ELSE NULL END DATAHORA,
        CASE PART.ESCALACAO WHEN 'Titular' THEN JOGO.FASE ELSE NULL END FASE
FROM JOGADOR JOGADOR
    LEFT JOIN PARTICIPA PART ON JOGADOR.NFIFA = PART.JOGADOR
    LEFT JOIN JOGO JOGO ON PART.JOGO = JOGO.NUMERO
    WHERE UPPER(JOGADOR.TIME) = 'BRASIL';

-- Exercício 2f:

/*
    Inserindo jogo de uma fase diferente para testar a consulta
*/
insert into Jogo
    (Numero, Fase, Time1, Time2, DataHora, NGols1, NGols2, Estadio, Arbitro, Assistente1, Assistente2, QuartoArbitro) values
    (SeqNumero.nextVal, 'Oitavas-de-final'   , 'Brasil'         , 'Coreia do Norte',
    to_date('15/06/2022 20:30', 'dd/mm/yyyy hh24:mi'), 4, 1, 'Estadio Ellis Park',
    'Oscar Ruiz', 'Stefano Ayroldi', 'Mike Pickel', 'Frank De Bleeckere');

-- 46 -> Daniel Alves da Silva
insert into participa (Jogador, Jogo, HoraEntrada, HoraSaida, NCartaoAm, NCartaoVerm, NFaltas, NPenaltes, NGols, Escalacao) values
    (46, SeqNumero.CURRVAL, to_date('20:30', 'hh24:mi'), to_date('22:15', 'hh24:mi'), 0, 0, 0, 0, 4, 'Titular');

SELECT JOGADOR.NFIFA, JOGADOR.NOME,
        SUM(CASE UPPER(JOGO.FASE) WHEN 'PRIMEIRA FASE' THEN PART.NGOLS ELSE 0 END) GOLSPRIMEIRAFASE,
        SUM(CASE UPPER(JOGO.FASE) WHEN 'OITAVAS-DE-FINAL' THEN PART.NGOLS ELSE 0 END) GOLSOITAVAS,
        SUM(CASE UPPER(JOGO.FASE) WHEN 'QUARTAS-DE-FINAL' THEN PART.NGOLS ELSE 0 END) GOLSQUARTAS,
        SUM(CASE UPPER(JOGO.FASE) WHEN 'SEMIFINAIS' THEN PART.NGOLS ELSE 0 END) GOLSSEMIFINAIS,
        SUM(CASE UPPER(JOGO.FASE) WHEN 'TERCEIRO LUGAR' THEN PART.NGOLS ELSE 0 END) GOLSTERCEIROLUGAR,
        SUM(CASE UPPER(JOGO.FASE) WHEN 'FINAL' THEN PART.NGOLS ELSE 0 END) GOLSFINAL
        FROM JOGADOR JOGADOR
    INNER JOIN PARTICIPA PART ON JOGADOR.NFIFA = PART.JOGADOR
    INNER JOIN JOGO JOGO ON PART.JOGO = JOGO.NUMERO
    WHERE UPPER(JOGADOR.TIME) = 'BRASIL' AND PART.HORAENTRADA IS NOT NULL -- atuou na partida
    GROUP BY JOGADOR.NFIFA, JOGADOR.NOME
    ORDER BY SUM(PART.NGOLS) DESC, NFIFA ASC;

/*
    A seguir está uma solução alternativa para o mesmo problema, mas existe a repetição de tuplas para um único jogador, logo julguei a solução acima como mais adequada.

    --SELECT JOGADOR.NFIFA, JOGADOR.NOME, SUM(PART.NGOLS) TOTALGOLS, JOGO.FASE FROM JOGADOR JOGADOR
    --    INNER JOIN PARTICIPA PART ON JOGADOR.NFIFA = PART.JOGADOR
    --    INNER JOIN JOGO JOGO ON PART.JOGO = JOGO.NUMERO
    --    WHERE UPPER(JOGADOR.TIME) = 'BRASIL' AND PART.HORAENTRADA IS NOT NULL -- atuou na partida
    --    GROUP BY JOGADOR.NFIFA, JOGADOR.NOME, JOGO.FASE
    --    ORDER BY SUM(PART.NGOLS) DESC, NFIFA ASC;
*/

-- Exercício 2g:
SELECT JOGADOR.NFIFA, JOGADOR.NOME, (SUM(PART.NCARTAOAM)+SUM(PART.NCARTAOVERM)) TOTALCARTOES, SUM(PART.NFALTAS) TOTALFALTAS, SUM(PART.NGOLS) TOTALGOLS
FROM JOGADOR JOGADOR
    INNER JOIN PARTICIPA PART ON JOGADOR.NFIFA = PART.JOGADOR
    INNER JOIN JOGO JOGO ON PART.JOGO = JOGO.NUMERO
    WHERE UPPER(JOGADOR.TIME) = 'BRASIL' AND UPPER(JOGADOR.POSICAO) = 'ATACANTE'
        AND JOGADOR.NFIFA IN -- select aninhado para pegar todos os jogadores que foram titulares em pelo menos um jogo da primeira fase, sem filtrar resultados da consulta original
            (SELECT P.JOGADOR FROM PARTICIPA P
                INNER JOIN JOGO J ON P.JOGO = J.NUMERO
                WHERE UPPER(P.ESCALACAO) = 'TITULAR' AND UPPER(J.FASE) = 'PRIMEIRA FASE')
    GROUP BY JOGADOR.NFIFA, JOGADOR.NOME
    HAVING SUM(CASE UPPER(JOGO.FASE) WHEN 'PRIMEIRA FASE' THEN PART.NGOLS ELSE 0 END) >= 1;

-- Exercício 2h:
SELECT JOGADOR.NOME, JOGADOR.TIME, COUNT(CASE PART.ESCALACAO WHEN 'Titular' THEN 'Titular' ELSE NULL END) PARTICIPACOES FROM JOGADOR JOGADOR
    LEFT JOIN PARTICIPA PART ON JOGADOR.NFIFA = PART.JOGADOR
    GROUP BY JOGADOR.NOME, JOGADOR.TIME;

-- Exercício 2i:

SELECT E.NOME ESTADIO, E.CIDADE,
        COUNT(CASE UPPER(JOGO.FASE) WHEN 'PRIMEIRA FASE' THEN 1 ELSE NULL END) JOGOSPRIMEIRAFASE,
        COUNT(CASE UPPER(JOGO.FASE) WHEN 'OITAVAS-DE-FINAL' THEN 1 ELSE NULL END) JOGOSOITAVAS,
        COUNT(CASE UPPER(JOGO.FASE) WHEN 'QUARTAS-DE-FINAL' THEN 1 ELSE NULL END) JOGOSQUARTAS,
        COUNT(CASE UPPER(JOGO.FASE) WHEN 'SEMIFINAIS' THEN 1 ELSE NULL END) JOGOSSEMIFINAIS,
        COUNT(CASE UPPER(JOGO.FASE) WHEN 'TERCEIRO LUGAR' THEN 1 ELSE NULL END) JOGOSTERCEIROLUGAR,
        COUNT(CASE UPPER(JOGO.FASE) WHEN 'FINAL' THEN 1 ELSE NULL END) JOGOSFINAL,
        SUM(CASE UPPER(JOGO.FASE) WHEN 'PRIMEIRA FASE' THEN JOGO.NGOLS1+JOGO.NGOLS2 ELSE 0 END) GOLSPRIMEIRAFASE,
        SUM(CASE UPPER(JOGO.FASE) WHEN 'OITAVAS-DE-FINAL' THEN JOGO.NGOLS1+JOGO.NGOLS2 ELSE 0 END) GOLSOITAVAS,
        SUM(CASE UPPER(JOGO.FASE) WHEN 'QUARTAS-DE-FINAL' THEN JOGO.NGOLS1+JOGO.NGOLS2 ELSE 0 END) GOLSQUARTAS,
        SUM(CASE UPPER(JOGO.FASE) WHEN 'SEMIFINAIS' THEN JOGO.NGOLS1+JOGO.NGOLS2 ELSE 0 END) GOLSSEMIFINAIS,
        SUM(CASE UPPER(JOGO.FASE) WHEN 'TERCEIRO LUGAR' THEN JOGO.NGOLS1+JOGO.NGOLS2 ELSE 0 END) GOLSTERCEIROLUGAR,
        SUM(CASE UPPER(JOGO.FASE) WHEN 'FINAL' THEN JOGO.NGOLS1+JOGO.NGOLS2 ELSE 0 END) GOLSFINAL
        FROM ESTADIO E
    INNER JOIN JOGO JOGO ON E.NOME = JOGO. ESTADIO
    GROUP BY E.NOME, E.CIDADE, JOGO.FASE;

/*
    Utilizei a mesma estratégia do exercício 2f para não haver duas linhas por estádio. Uma solução alternativa está comentada abaixo.
    Ambas as soluções tem desempenhos similares, segunda o plano de consultas do Oracle.
    
    SELECT E.NOME, E.CIDADE, JOGO.FASE, COUNT(JOGO.ESTADIO) NJOGOS, SUM(JOGO.NGOLS1)+SUM(JOGO.NGOLS2) TOTALGOLS FROM ESTADIO E
    INNER JOIN JOGO JOGO ON E.NOME = JOGO.ESTADIO
    GROUP BY E.NOME, E.CIDADE, JOGO.FASE;
*/

-- Exercício 2j1:
SELECT T.PAIS, T.NFIFA FROM TIME T
    WHERE NOT EXISTS (SELECT J.NUMERO FROM JOGO J WHERE FASE <> 'Primeira Fase' AND (TIME1=T.PAIS OR TIME2=T.PAIS));

/* Verificando plano de consula */
EXPLAIN PLAN FOR
SELECT T.PAIS, T.NFIFA FROM TIME T
    WHERE NOT EXISTS (SELECT J.NUMERO FROM JOGO J WHERE FASE <> 'Primeira Fase' AND (TIME1=T.PAIS OR TIME2=T.PAIS));
SELECT plan_table_output FROM TABLE(dbms_xplan.display());

/*
Resultado do plano de consulta da query com consultas correlacionadas:

-------------------------------------------------------------------------------------------
| Id  | Operation               | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT        |                  |    31 |  2015 |     9  (12)| 00:00:01 |
|*  1 |  HASH JOIN ANTI         |                  |    31 |  2015 |     9  (12)| 00:00:01 |
|   2 |   VIEW                  | index$_join$_001 |    32 |   416 |     3  (34)| 00:00:01 |
|*  3 |    HASH JOIN            |                  |       |       |            |          |
|   4 |     INDEX FAST FULL SCAN| SYS_C001112369   |    32 |   416 |     1   (0)| 00:00:01 |
|   5 |     INDEX FAST FULL SCAN| UK_TIME          |    32 |   416 |     1   (0)| 00:00:01 |
|   6 |   VIEW                  | VW_SQ_1          |     2 |   104 |     6   (0)| 00:00:01 |
|   7 |    UNION-ALL            |                  |       |       |            |          |
|*  8 |     TABLE ACCESS FULL   | JOGO             |     1 |    24 |     3   (0)| 00:00:01 |
|*  9 |     TABLE ACCESS FULL   | JOGO             |     1 |    24 |     3   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("VW_COL_1"="T"."PAIS")
   3 - access(ROWID=ROWID)
   8 - filter("FASE"<>'Primeira Fase')
   9 - filter("FASE"<>'Primeira Fase')
*/

-- Exercício 2j2:
SELECT T.PAIS, T.NFIFA FROM TIME T
    WHERE T.PAIS NOT IN (SELECT TIME1 FROM JOGO WHERE FASE <> 'Primeira Fase')
        AND T.PAIS NOT IN (SELECT TIME2 FROM JOGO WHERE FASE <> 'Primeira Fase');

/* Verificando plano de consula */
EXPLAIN PLAN FOR
SELECT T.PAIS, T.NFIFA FROM TIME T
    WHERE T.PAIS NOT IN (SELECT TIME1 FROM JOGO WHERE FASE <> 'Primeira Fase')
        AND T.PAIS NOT IN (SELECT TIME2 FROM JOGO WHERE FASE <> 'Primeira Fase');
SELECT plan_table_output FROM TABLE(dbms_xplan.display());

/*
Resultado do plano de consulta da query com consultas não-correlacionadas:
---------------------------------------------------------------------------------------------
| Id  | Operation                | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT         |                  |     1 |    61 |    10  (20)| 00:00:01 |
|*  1 |  HASH JOIN ANTI          |                  |     1 |    61 |    10  (20)| 00:00:01 |
|*  2 |   HASH JOIN ANTI         |                  |    31 |  1147 |     6  (17)| 00:00:01 |
|   3 |    VIEW                  | index$_join$_001 |    32 |   416 |     3  (34)| 00:00:01 |
|*  4 |     HASH JOIN            |                  |       |       |            |          |
|   5 |      INDEX FAST FULL SCAN| SYS_C001112369   |    32 |   416 |     1   (0)| 00:00:01 |
|   6 |      INDEX FAST FULL SCAN| UK_TIME          |    32 |   416 |     1   (0)| 00:00:01 |
|*  7 |    TABLE ACCESS FULL     | JOGO             |     1 |    24 |     3   (0)| 00:00:01 |
|*  8 |   TABLE ACCESS FULL      | JOGO             |     1 |    24 |     3   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("T"."PAIS"="TIME1")
   2 - access("T"."PAIS"="TIME2")
   4 - access(ROWID=ROWID)
   7 - filter("FASE"<>'Primeira Fase')
   8 - filter("FASE"<>'Primeira Fase')
*/

/*
    Podemos ver, pelos planos de consulta, que o custo geral da query com consultas aninhadas não-correlacionadas é mais eficiente, principalmente quanto ao acesso à disco.
*/


-- Exercício 2k:

/* Nesta query, tentei utilizar algo como o operador de divisão da álgebra relacional*/
SELECT JOGADOR.NOME, JOGADOR.NFIFA FROM JOGADOR JOGADOR
    WHERE NOT EXISTS(
        (SELECT JOGO.NUMERO FROM JOGO JOGO WHERE JOGO.TIME1 = JOGADOR.TIME OR JOGO.TIME2 = JOGADOR.TIME)
        MINUS
        (SELECT PART.JOGO FROM PARTICIPA PART WHERE PART.JOGADOR = JOGADOR.NFIFA AND ESCALACAO = 'Titular'));
