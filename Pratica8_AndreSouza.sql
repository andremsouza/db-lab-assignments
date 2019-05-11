/*
    Nome: André Moreira Souza    N°USP: 9778985
    Prática 8 - PL/SQL - Coleções
*/

-- Exercício 1 --------------------------------------------------------------------------------------------------------

/*
    Utilizando cursor explícito para o "CURSOR FOR LOOP", para facilitar a definição da coleção T_TREINOS.
    Para quando não existem tuplas no resultado da consulta, foi criada uma exceção, assim evitando erros de acesso indevido.
*/

DECLARE
    CURSOR c1 IS SELECT TI.PAIS TIME, TI.NFIFA NFIFA, ES.NOME ESTADIO, ES.CIDADE CIDADE, TR.DTATREINO DTATREINO
        FROM TREINA TR
        INNER JOIN TIME TI ON TI.PAIS = TR.TIME
        INNER JOIN ESTADIO ES ON ES.NOME = TR.ESTADIO;
    TYPE T_TREINOS IS TABLE OF c1%ROWTYPE;
    v_treinos T_TREINOS := T_TREINOS();
    e_notreinos EXCEPTION;
BEGIN
    -- Atribuindo tuplas do resultado do cursor
    FOR treino_rec IN c1 LOOP
        v_treinos.extend(1);
        v_treinos(v_treinos.LAST) := treino_rec;
    END LOOP;
    -- CURSOR FOR LOOP abre e fecha o cursor automaticamente -> Sem necessidade do comando CLOSE c1;
    -- Imprimindo output
    IF v_treinos.count = 0 THEN
        RAISE e_notreinos;
    END IF;
    DBMS_OUTPUT.PUT_LINE('TIME' || chr(9) || 'NFIFA' || chr(9) || 'ESTADIO' || chr(9) || 'CIDADE' || chr(9) || 'DTATREINO');
    FOR i IN v_treinos.FIRST .. v_treinos.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(v_treinos(i).time || chr(9) || v_treinos(i).nfifa || chr(9) || v_treinos(i).estadio || chr(9) ||
            v_treinos(i).cidade || chr(9) || v_treinos(i).dtatreino);
    END LOOP;
    EXCEPTION
        WHEN SUBSCRIPT_BEYOND_COUNT THEN DBMS_OUTPUT.PUT_LINE('Acesso indevido à uma coleção (elemento inexistente).'); ROLLBACK;
        WHEN COLLECTION_IS_NULL THEN DBMS_OUTPUT.PUT_LINE('Coleção não inicializada.'); ROLLBACK;
        WHEN e_notreinos THEN DBMS_OUTPUT.PUT_LINE('Não existem treinos na base atual.'); ROLLBACK;
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('ERRO NRO: ' || SQLCODE || '; MENSAGEM: ' || SQLERRM); ROLLBACK;
END;

/*
    Resultado esperado para a base de dados padrão:

    TIME	NFIFA	ESTADIO	CIDADE	DTATREINO
    Africa do Sul	2	Estadio Soccer City	Joanesburgo	10/06/22
    Mexico	3	Estadio Soccer City	Joanesburgo	10/06/22
    Uruguai	4	Estadio Green Point	Cidade do Cabo	10/06/22
    Franca	5	Estadio Green Point	Cidade do Cabo	10/06/22
    Argentina	6	Estadio Ellis Park	Joanesburgo	11/06/22
    Nigeria	7	Estadio Ellis Park	Joanesburgo	11/06/22
    Coreia do Sul	8	Estadio Nelson Mandela Bay	Nelson Mandela Bay/Port Elizabeth	11/06/22
    Grecia	9	Estadio Nelson Mandela Bay	Nelson Mandela Bay/Port Elizabeth	11/06/22
    Inglaterra	10	Estadio Royal Bafokeng	Rustemburgo	11/06/22
    Estados Unidos	11	Estadio Royal Bafokeng	Rustemburgo	11/06/22
    Argelia	12	Estadio Peter Mokaba	Polokwane	12/06/22
    Eslovenia	13	Estadio Peter Mokaba	Polokwane	12/06/22
    Alemanha	14	Estadio Moses Mabhida	Durban	12/06/22
    Australia	15	Estadio Moses Mabhida	Durban	12/06/22
    Servia	16	Estadio Loftus Versfeld	Tshwane/Pretoria	12/06/22
    Gana	17	Estadio Loftus Versfeld	Tshwane/Pretoria	12/06/22
    Holanda	18	Estadio Soccer City	Joanesburgo	13/06/22
    Dinamarca	19	Estadio Soccer City	Joanesburgo	13/06/22
    Japao	20	Estadio Free State	Mangaung/Bloemfontein	13/06/22
    Camaroes	21	Estadio Free State	Mangaung/Bloemfontein	13/06/22
    Italia	22	Estadio Green Point	Cidade do Cabo	13/06/22
    Paraguai	23	Estadio Green Point	Cidade do Cabo	13/06/22
    Nova Zelandia	24	Estadio Royal Bafokeng	Rustemburgo	14/06/22
    Eslovaquia	25	Estadio Royal Bafokeng	Rustemburgo	14/06/22
    Brasil	26	Estadio Ellis Park	Joanesburgo	14/06/22
    Coreia do Norte	27	Estadio Ellis Park	Joanesburgo	14/06/22
    Costa do Marfim	28	Estadio Nelson Mandela Bay	Nelson Mandela Bay/Port Elizabeth	14/06/22
    Portugal	29	Estadio Nelson Mandela Bay	Nelson Mandela Bay/Port Elizabeth	14/06/22
    Espanha	30	Estadio Moses Mabhida	Durban	15/06/22
    Suica	31	Estadio Moses Mabhida	Durban	15/06/22
    Honduras	32	Estadio Mbombela	Nelspruit	15/06/22
    Chile	33	Estadio Mbombela	Nelspruit	15/06/22
*/

-- Exercício 2 --------------------------------------------------------------------------------------------------------

/*
    Utilizei uma Index-by Table para armazenar os resultados da consulta. Julguei esta coleção mais adequada pois o tamanho máximo de elementos não precisa ser definido na declaração. Como, a princípio, o número de tuplas não é conhecido, esta coleção permite uma maior flexibilidade, e viabiliza o "BULK COLLECT", diferentemente das outras.

    Assim como no exercício anterior, foi criada uma exceção para o caso onde não existem tuplas resultantes da consulta.
*/

DECLARE
    CURSOR c1 IS SELECT T1.GRUPO GRUPO, J.DATAHORA DATAHORA, J.TIME1 TIME1, J.TIME2 TIME2,
        J.NGOLS1 NGOLS1, J.NGOLS2 NGOLS2, J.ESTADIO ESTADIO FROM JOGO J
        INNER JOIN TIME T1 ON T1.PAIS = J.TIME1
        WHERE UPPER(J.FASE) = 'PRIMEIRA FASE';
    TYPE T_JOGO IS RECORD (
        GRUPO TIME.GRUPO%TYPE,
        DATAHORA JOGO.DATAHORA%TYPE,
        TIME1 JOGO.TIME1%TYPE,
        TIME2 JOGO.TIME2%TYPE,
        NGOLS1 JOGO.NGOLS1%TYPE,
        NGOLS2 JOGO.NGOLS2%TYPE,
        ESTADIO JOGO.ESTADIO%TYPE
    );
    TYPE T_JOGOS IS TABLE OF T_JOGO INDEX BY PLS_INTEGER;
    v_jogos T_JOGOS;
    e_nogames EXCEPTION;
BEGIN
    -- Obtendo resultado da consulta e atribuindo à variável v_jogos
    OPEN c1;
    FETCH c1 BULK COLLECT INTO v_jogos;
    CLOSE c1;
    -- Imprimindo output
    IF v_jogos.COUNT = 0 THEN
        RAISE e_nogames;
    END IF;
    DBMS_OUTPUT.PUT_LINE('GRUPO' || chr(9) || 'DATAHORA' || chr(9) || 'TIME1' || chr(9) || 'TIME2' || chr(9) || 'NGOLS1' ||
        chr(9) || 'NGOLS2' || chr(9) || 'ESTADIO');
    FOR i in v_jogos.FIRST .. v_jogos.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(v_jogos(i).grupo || chr(9) || v_jogos(i).datahora || chr(9) || v_jogos(i).time1 || chr(9) ||
            v_jogos(i).time2 || chr(9) || v_jogos(i).ngols1 || chr(9) || v_jogos(i).ngols2 || chr(9) || v_jogos(i).estadio);
    END LOOP;
    EXCEPTION
        WHEN SUBSCRIPT_BEYOND_COUNT THEN DBMS_OUTPUT.PUT_LINE('Acesso indevido à uma coleção (elemento fora dos limites).'); ROLLBACK;
        WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Tentativa de acesso a elemento sem atribuição'); ROLLBACK;
        WHEN VALUE_ERROR THEN DBMS_OUTPUT.PUT_LINE('Tentativa de acesso a um elemento fora do intervalo do tipo de dados PLS_INTEGER.'); ROLLBACK;
        WHEN e_nogames THEN DBMS_OUTPUT.PUT_LINE('Não existem jogos na base de dados.'); ROLLBACK;
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('ERRO NRO: ' || SQLCODE || '; MENSAGEM: ' || SQLERRM); ROLLBACK;
END;

/*
    Resultado esperado na base de dados padrão:
    GRUPO	DATAHORA	TIME1	TIME2	NGOLS1	NGOLS2	ESTADIO
    A	11/06/22	Africa do Sul	Mexico	1	0	Estadio Soccer City
    A	11/06/22	Uruguai	Franca	0	2	Estadio Green Point
    B	12/06/22	Coreia do Sul	Grecia	0	1	Estadio Nelson Mandela Bay
    A	12/06/22	Argentina	Nigeria	1	1	Estadio Ellis Park
    C	12/06/22	Inglaterra	Estados Unidos	3	1	Estadio Royal Bafokeng
    C	13/06/22	Argelia	Eslovenia	1	1	Estadio Peter Mokaba
    D	13/06/22	Servia	Gana	1	3	Estadio Loftus Versfeld
    D	13/06/22	Alemanha	Australia	3	1	Estadio Moses Mabhida
    E	14/06/22	Holanda	Dinamarca	1	0	Estadio Soccer City
    E	14/06/22	Japao	Camaroes	2	3	Estadio Free State
    F	14/06/22	Italia	Paraguai	3	1	Estadio Green Point
    F	15/06/22	Nova Zelandia	Eslovaquia	1	1	Estadio Royal Bafokeng
    G	15/06/22	Costa do Marfim	Portugal	1	2	Estadio Nelson Mandela Bay
    G	15/06/22	Brasil	Coreia do Norte	4	1	Estadio Ellis Park
    H	16/06/22	Honduras	Chile	0	1	Estadio Mbombela
    H	16/06/22	Espanha	Suica	2	1	Estadio Moses Mabhida
    A	16/06/22	Africa do Sul	Uruguai	0	0	Estadio Loftus Versfeld
    A	17/06/22	Argentina	Coreia do Sul	3	0	Estadio Soccer City
    B	17/06/22	Grecia	Nigeria	0	0	Estadio Free State
    A	17/06/22	Franca	Mexico	4	0	Estadio Peter Mokaba
    D	18/06/22	Alemanha	Servia	3	2	Estadio Nelson Mandela Bay
    C	18/06/22	Eslovenia	Estados Unidos	1	1	Estadio Ellis Park
    C	18/06/22	Inglaterra	Argelia	4	1	Estadio Green Point
    E	19/06/22	Holanda	Japao	4	1	Estadio Moses Mabhida
    D	19/06/22	Gana	Australia	1	1	Estadio Royal Bafokeng
    E	19/06/22	Camaroes	Dinamarca	3	0	Estadio Loftus Versfeld
    F	20/06/22	Eslovaquia	Paraguai	1	2	Estadio Free State
    F	20/06/22	Italia	Nova Zelandia	3	1	Estadio Mbombela
    G	20/06/22	Brasil	Costa do Marfim	3	1	Estadio Soccer City
    G	21/06/22	Portugal	Coreia do Norte	4	0	Estadio Green Point
    H	21/06/22	Chile	Suica	1	1	Estadio Nelson Mandela Bay
    H	21/06/22	Espanha	Honduras	4	0	Estadio Ellis Park
    A	22/06/22	Franca	Africa do Sul	1	1	Estadio Free State
    A	22/06/22	Mexico	Uruguai	0	1	Estadio Royal Bafokeng
    B	22/06/22	Grecia	Argentina	0	1	Estadio Peter Mokaba
    B	22/06/22	Nigeria	Coreia do Sul	3	2	Estadio Moses Mabhida
    C	23/06/22	Eslovenia	Inglaterra	0	0	Estadio Nelson Mandela Bay
    C	23/06/22	Estados Unidos	Argelia	0	0	Estadio Loftus Versfeld
    D	23/06/22	Australia	Servia	0	0	Estadio Mbombela
    D	23/06/22	Gana	Alemanha	0	1	Estadio Soccer City
    F	24/06/22	Paraguai	Nova Zelandia	0	0	Estadio Peter Mokaba
    F	24/06/22	Eslovaquia	Italia	0	0	Estadio Ellis Park
    E	24/06/22	Dinamarca	Japao	0	0	Estadio Royal Bafokeng
    E	24/06/22	Camaroes	Holanda	1	1	Estadio Green Point
    G	25/06/22	Portugal	Brasil	0	1	Estadio Moses Mabhida
    G	25/06/22	Coreia do Norte	Costa do Marfim	1	1	Estadio Mbombela
    H	25/06/22	Chile	Espanha	1	2	Estadio Loftus Versfeld
    H	25/06/22	Suica	Honduras	2	2	Estadio Free State
*/

-- Exercício 3 --------------------------------------------------------------------------------------------------------

/*
    Consulta escolhida: sumarização dos dados de jogadores e seus desempenhos nas partidas.
    Utilizando uma Index-by Table, como no exercício anterior.
*/

DECLARE
    -- definindo registro para a consulta desejada
    TYPE T_JOGADOR IS RECORD (
            NFIFA JOGADOR.NFIFA%TYPE,
            NOME JOGADOR.NOME%TYPE,
            CAPITAO JOGADOR.CAPITAO%TYPE,
            TIME JOGADOR.TIME%TYPE,
            MEDIA_TEMPOJOGADO NUMBER,
            NCARTOES NUMBER,
            NFALTAS NUMBER,
            NPENALTES NUMBER,
            NGOLS NUMBER
        );
    TYPE T_JOGADORES IS TABLE OF T_JOGADOR INDEX BY PLS_INTEGER;
    v_jogadores T_JOGADORES;
    e_noplayers EXCEPTION;
BEGIN
    -- realizando consulta e atribuindo à coleção
    SELECT J.NFIFA, J.NOME, J.CAPITAO, J.TIME,
        AVG(CASE WHEN P.HORAENTRADA IS NULL OR P.HORASAIDA IS NULL THEN NULL ELSE (P.HORASAIDA - P.HORAENTRADA)*24*60 END) MEDIA_TEMPOJOGADO,
        SUM(NVL(P.NCARTAOAM + P.NCARTAOVERM, 0)) NCARTOES,
        SUM(NVL(P.NFALTAS, 0)) NFALTAS,
        SUM(NVL(P.NPENALTES, 0)) NPENALTES,
        SUM(NVL(P.NGOLS, 0)) NGOLS
        BULK COLLECT INTO v_jogadores -- BULK COLLECT sem o uso de cursores (explícitos)
        FROM JOGADOR J
        LEFT OUTER JOIN PARTICIPA P ON J.NFIFA = P.JOGADOR
        GROUP BY J.NFIFA, J.NOME, J.CAPITAO, J.TIME
        ORDER BY MEDIA_TEMPOJOGADO ASC;

    -- Imprimindo output
    DBMS_OUTPUT.PUT_LINE('NFIFA' || chr(9) || 'NOME' || chr(9) || 'CAPITAO' || chr(9) || 'TIME' || chr(9) ||
        'MEDIA_TEMPOJOGADO' || chr(9) || 'NCARTOES' || chr(9) || 'NFALTAS' || chr(9) || 'NPENALTES' || chr(9) || 'NGOLS');
    IF v_jogadores.count = 0 THEN
        RAISE e_noplayers;
    END IF;
    FOR i in v_jogadores.FIRST .. v_jogadores.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(v_jogadores(i).NFIFA || chr(9) || v_jogadores(i).NOME || chr(9) || v_jogadores(i).CAPITAO || 
            chr(9) || v_jogadores(i).TIME || chr(9) || v_jogadores(i).MEDIA_TEMPOJOGADO || chr(9) || v_jogadores(i).NCARTOES || 
            chr(9) || v_jogadores(i).NFALTAS || chr(9) || v_jogadores(i).NPENALTES || chr(9) || v_jogadores(i).NGOLS);
    END LOOP;
    EXCEPTION
        WHEN SUBSCRIPT_BEYOND_COUNT THEN DBMS_OUTPUT.PUT_LINE('Acesso indevido à uma coleção (elemento fora dos limites).'); ROLLBACK;
        WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Tentativa de acesso a elemento sem atribuição'); ROLLBACK;
        WHEN VALUE_ERROR THEN DBMS_OUTPUT.PUT_LINE('Tentativa de acesso a um elemento fora do intervalo do tipo de dados PLS_INTEGER.'); ROLLBACK;
        WHEN e_noplayers THEN DBMS_OUTPUT.PUT_LINE('Não existem jogadores na base de dados.'); ROLLBACK;
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('ERRO NRO: ' || SQLCODE || '; MENSAGEM: ' || SQLERRM); ROLLBACK;
END;

/*
    Resultado esperado para a base de dados padrão:
    
    NFIFA	NOME	CAPITAO	TIME	MEDIA_TEMPOJOGADO	NCARTOES	NFALTAS	NPENALTES	NGOLS
    60	Anderson Luis da Silva	N	Brasil	8	0	0	0	0
    63	Nilmar Honorato da Silva	N	Brasil	13	0	0	0	1
    46	Daniel Alves da Silva	N	Brasil	24,99999999999999999999999999999999999998	0	0	0	1
    80	Kim Kum II	N	Coreia do Norte	36,99999999999999999999999999999999999994	0	0	0	0
    72	Nam Chol Pak	S	Coreia do Norte	67,9999999999999999999999999999999999998	0	0	0	0
    45	Adriano Leite Ribeiro	N	Brasil	79,0000000000000000000000000000000000002	0	0	0	0
    64	Ramires Santos do Nascimento	N	Brasil	79,9999999999999999999999999999999999998	0	0	0	0
    65	Robson de Souza	N	Brasil	91,9999999999999999999999999999999999998	0	0	0	1
    58	Lucimar da Silva Ferreira	S	Brasil	97,0000000000000000000000000000000000002	0	0	0	0
    61	Maicon Douglas Sisenando	N	Brasil	99	0	0	0	0
    55	Julio Cesar Soares de Espindola	N	Brasil	105	0	0	0	1
    67	Ri Myong Guk	N	Coreia do Norte	105	0	0	0	0
    62	Michel Fernandes Bastos	N	Brasil	105	0	0	0	0
    (...)

*/