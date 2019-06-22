/*
	Nome: André Moreira Souza    N°USP: 9778985
	Prática 12 - Transações
*/

-- Exercício 1 ----------------------------------------------------------------

-- Utilizando nível de isolamento READ COMMITED -------------------------------

-- i -> conexão aberta.
-- ii -> 2ª conexão aberta.
-- iii -- * Sessão 2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
/*
    Saída: Transaction ISOLATION bem-sucedido.
*/
-- iv -- * Sessão 2
SELECT E.NOME, E.PAIS, COUNT(PT.PAISTRANSM) FROM EMISSORA E
    LEFT JOIN PAISTRANSM PT ON E.NOME = PT.NOMEEMISSORA AND E.PAIS = PT.PAISEMISSORA
    GROUP BY E.NOME, E.PAIS;
/*
    Output esperado (para a base inicial):
    NOME    PAIS    COUNT(PT.PAISTRANSM)
    Broadcasting Organization of Nigeria	Nigeria	6
    Televisa	Mexico	1
    Radio Nacional	Argentina	1
    Venevision	Venezuela	1
    BBC	Inglaterra	3
    CBC	Canada	1
    Canal 7	Argentina	1
    Cuatro	Espanha	1
    NTV	Nova Zelandia	1
    RDP Antena 1	Portugal	1
    RTP	Portugal	1
    RTSH	Albania	1
    Rede Globo	Brasil	1
    TF1	Franca	1
    ESPN Brasil	Brasil	1
    ESPN360	Estados Unidos	1
    RAI	Italia	1
    Sport TV	Portugal	1
    VTV	Vietna	1
    ABC	Albania	1
    Sport TV	Brasil	1
    SuperSport	Africa do Sul	1
    Rede Bandeirantes	Brasil	1
    SIC	Portugal	1
*/
-- v -- * Sessão 1
DELETE FROM PAISTRANSM WHERE NOMEEMISSORA='Rede Globo' AND PAISEMISSORA='Brasil';
/*
    Tabela, após a remoção (na sessão 1):
    Broadcasting Organization of Nigeria	Nigeria	6
    Televisa	Mexico	1
    Radio Nacional	Argentina	1
    Venevision	Venezuela	1
    BBC	Inglaterra	3
    CBC	Canada	1
    Canal 7	Argentina	1
    Cuatro	Espanha	1
    NTV	Nova Zelandia	1
    RDP Antena 1	Portugal	1
    RTP	Portugal	1
    RTSH	Albania	1
    TF1	Franca	1
    Rede Globo	Brasil	0
    ESPN Brasil	Brasil	1
    ESPN360	Estados Unidos	1
    RAI	Italia	1
    Sport TV	Portugal	1
    VTV	Vietna	1
    ABC	Albania	1
    Sport TV	Brasil	1
    SuperSport	Africa do Sul	1
    Rede Bandeirantes	Brasil	1
    SIC	Portugal	1
*/
-- vi -- * Sessão 2
SELECT E.NOME, E.PAIS, COUNT(PT.PAISTRANSM) FROM EMISSORA E
    LEFT JOIN PAISTRANSM PT ON E.NOME = PT.NOMEEMISSORA AND E.PAIS = PT.PAISEMISSORA
    GROUP BY E.NOME, E.PAIS;

/*
    Resultado:
    Broadcasting Organization of Nigeria	Nigeria	6
    Televisa	Mexico	1
    Radio Nacional	Argentina	1
    Venevision	Venezuela	1
    BBC	Inglaterra	3
    CBC	Canada	1
    Canal 7	Argentina	1
    Cuatro	Espanha	1
    NTV	Nova Zelandia	1
    RDP Antena 1	Portugal	1
    RTP	Portugal	1
    RTSH	Albania	1
    Rede Globo	Brasil	1
    TF1	Franca	1
    ESPN Brasil	Brasil	1
    ESPN360	Estados Unidos	1
    RAI	Italia	1
    Sport TV	Portugal	1
    VTV	Vietna	1
    ABC	Albania	1
    Sport TV	Brasil	1
    SuperSport	Africa do Sul	1
    Rede Bandeirantes	Brasil	1
    SIC	Portugal	1
    
    Percebe-se que a contagem de países de transmissão para a emissora
    'Rede Globo' permaneceu o mesmo para a sessão 2, mesmo após a remoção da
    tupla na sessão 1.

    Isso acontece pois, após a operação de DELETE, ainda não foi executado o
    comando COMMIT. Sendo assim, as mudanças da  DML ainda não foram efetivadas
    na base de dados.
    
    Para ambos os níveis de isolamento, este é o comportamento esperado.
*/
-- vii -- * Sessão 1
COMMIT;
/*
    Output: Commit concluído
*/
-- viii -- * Sessão 2
SELECT E.NOME, E.PAIS, COUNT(PT.PAISTRANSM) FROM EMISSORA E
    LEFT JOIN PAISTRANSM PT ON E.NOME = PT.NOMEEMISSORA AND E.PAIS = PT.PAISEMISSORA
    GROUP BY E.NOME, E.PAIS;
/*
    Resultado:
    Broadcasting Organization of Nigeria	Nigeria	6
    Televisa	Mexico	1
    Radio Nacional	Argentina	1
    Venevision	Venezuela	1
    BBC	Inglaterra	3
    CBC	Canada	1
    Canal 7	Argentina	1
    Cuatro	Espanha	1
    NTV	Nova Zelandia	1
    RDP Antena 1	Portugal	1
    RTP	Portugal	1
    RTSH	Albania	1
    TF1	Franca	1
    Rede Globo	Brasil	0
    ESPN Brasil	Brasil	1
    ESPN360	Estados Unidos	1
    RAI	Italia	1
    Sport TV	Portugal	1
    VTV	Vietna	1
    ABC	Albania	1
    Sport TV	Brasil	1
    SuperSport	Africa do Sul	1
    Rede Bandeirantes	Brasil	1
    SIC	Portugal	1

    A remoção na sessão 1 foi refletida na consulta da sessão 2.
    
    O nível de isolamento READ COMMITED permite que uma transação leia
    apenas dados que foram efetuados (COMMIT) na base de dados.
    
    Neste cenário, após a operação de COMMIT, as alterações da DML são
    efetivadas na base de dados. Com o nível de isolamento READ COMMITED, a
    sessão 2 consegue visualizar e operar sobre os dados modificados pela
    sessão 1 neste ponto.
*/
-- ix -- * Sessão 2
COMMIT;
/*
    Output: Commit concluído.
*/
-- x -- * Sessão 2
SELECT E.NOME, E.PAIS, COUNT(PT.PAISTRANSM) FROM EMISSORA E
    LEFT JOIN PAISTRANSM PT ON E.NOME = PT.NOMEEMISSORA AND E.PAIS = PT.PAISEMISSORA
    GROUP BY E.NOME, E.PAIS;
/*
    Result:
    Broadcasting Organization of Nigeria	Nigeria	6
    Televisa	Mexico	1
    Radio Nacional	Argentina	1
    Venevision	Venezuela	1
    BBC	Inglaterra	3
    CBC	Canada	1
    Canal 7	Argentina	1
    Cuatro	Espanha	1
    NTV	Nova Zelandia	1
    RDP Antena 1	Portugal	1
    RTP	Portugal	1
    RTSH	Albania	1
    TF1	Franca	1
    Rede Globo	Brasil	0
    ESPN Brasil	Brasil	1
    ESPN360	Estados Unidos	1
    RAI	Italia	1
    Sport TV	Portugal	1
    VTV	Vietna	1
    ABC	Albania	1
    Sport TV	Brasil	1
    SuperSport	Africa do Sul	1
    Rede Bandeirantes	Brasil	1
    SIC	Portugal	1

    O resultado está como o esperado, ou seja, a remoção na sessão 1 foi
    corretamente refletida na sessão 2.
    Para o nível de isolamento READ COMMITED, não houveram diferenças nos dados
    entre os passos 8 e 10, pois no passo 8 já era possível evidenciar as
    modificações na sessão 2, devido ao commit feito na sessão 1.
*/

-- Utilizando nível de isolamento SERIALIZABLE --------------------------------

-- i -> conexão aberta.
-- ii -> 2ª conexão aberta.
-- iii -- * Sessão 2
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
/*
    Output: Transaction ISOLATION bem-sucedido.
*/
-- iv -- * Sessão 2
SELECT E.NOME, E.PAIS, COUNT(PT.PAISTRANSM) FROM EMISSORA E
    LEFT JOIN PAISTRANSM PT ON E.NOME = PT.NOMEEMISSORA AND E.PAIS = PT.PAISEMISSORA
    GROUP BY E.NOME, E.PAIS;
/*
    Output esperado (para a base inicial):
    Broadcasting Organization of Nigeria	Nigeria	6
    Televisa	Mexico	1
    Radio Nacional	Argentina	1
    Venevision	Venezuela	1
    BBC	Inglaterra	3
    CBC	Canada	1
    Canal 7	Argentina	1
    Cuatro	Espanha	1
    NTV	Nova Zelandia	1
    RDP Antena 1	Portugal	1
    RTP	Portugal	1
    RTSH	Albania	1
    Rede Globo	Brasil	1
    TF1	Franca	1
    ESPN Brasil	Brasil	1
    ESPN360	Estados Unidos	1
    RAI	Italia	1
    Sport TV	Portugal	1
    VTV	Vietna	1
    ABC	Albania	1
    Sport TV	Brasil	1
    SuperSport	Africa do Sul	1
    Rede Bandeirantes	Brasil	1
    SIC	Portugal	1
*/
-- v -- * Sessão 1
DELETE FROM PAISTRANSM WHERE NOMEEMISSORA='Rede Globo' AND PAISEMISSORA='Brasil';
/*
    Tabela, após a remoção (na sessão 1):
    Broadcasting Organization of Nigeria	Nigeria	6
    Televisa	Mexico	1
    Radio Nacional	Argentina	1
    Venevision	Venezuela	1
    BBC	Inglaterra	3
    CBC	Canada	1
    Canal 7	Argentina	1
    Cuatro	Espanha	1
    NTV	Nova Zelandia	1
    RDP Antena 1	Portugal	1
    RTP	Portugal	1
    RTSH	Albania	1
    TF1	Franca	1
    Rede Globo	Brasil	0
    ESPN Brasil	Brasil	1
    ESPN360	Estados Unidos	1
    RAI	Italia	1
    Sport TV	Portugal	1
    VTV	Vietna	1
    ABC	Albania	1
    Sport TV	Brasil	1
    SuperSport	Africa do Sul	1
    Rede Bandeirantes	Brasil	1
    SIC	Portugal	1
*/
-- vi -- * Sessão 2
SELECT E.NOME, E.PAIS, COUNT(PT.PAISTRANSM) FROM EMISSORA E
    LEFT JOIN PAISTRANSM PT ON E.NOME = PT.NOMEEMISSORA AND E.PAIS = PT.PAISEMISSORA
    GROUP BY E.NOME, E.PAIS;
/*
    Resultado:
    Broadcasting Organization of Nigeria	Nigeria	6
    Televisa	Mexico	1
    Radio Nacional	Argentina	1
    Venevision	Venezuela	1
    BBC	Inglaterra	3
    CBC	Canada	1
    Canal 7	Argentina	1
    Cuatro	Espanha	1
    NTV	Nova Zelandia	1
    RDP Antena 1	Portugal	1
    RTP	Portugal	1
    RTSH	Albania	1
    Rede Globo	Brasil	1
    TF1	Franca	1
    ESPN Brasil	Brasil	1
    ESPN360	Estados Unidos	1
    RAI	Italia	1
    Sport TV	Portugal	1
    VTV	Vietna	1
    ABC	Albania	1
    Sport TV	Brasil	1
    SuperSport	Africa do Sul	1
    Rede Bandeirantes	Brasil	1
    SIC	Portugal	1

    Na sessão 2, não foram refeletidas as alterações da remoção realizada na
    sessão 1.
    Como explicado anteriormente, modificações feitas por operações DML não são
    efetuados até que haja o comando COMMIT pela sessão em questão (sessão 1).
*/
-- vii -- * Sessão 1
COMMIT;
/*
    Output: Commit Concluído.
*/
-- viii -- * Sessão 2
SELECT E.NOME, E.PAIS, COUNT(PT.PAISTRANSM) FROM EMISSORA E
    LEFT JOIN PAISTRANSM PT ON E.NOME = PT.NOMEEMISSORA AND E.PAIS = PT.PAISEMISSORA
    GROUP BY E.NOME, E.PAIS;
/*
    Resultado:
    Broadcasting Organization of Nigeria	Nigeria	6
    Televisa	Mexico	1
    Radio Nacional	Argentina	1
    Venevision	Venezuela	1
    BBC	Inglaterra	3
    CBC	Canada	1
    Canal 7	Argentina	1
    Cuatro	Espanha	1
    NTV	Nova Zelandia	1
    RDP Antena 1	Portugal	1
    RTP	Portugal	1
    RTSH	Albania	1
    Rede Globo	Brasil	1
    TF1	Franca	1
    ESPN Brasil	Brasil	1
    ESPN360	Estados Unidos	1
    RAI	Italia	1
    Sport TV	Portugal	1
    VTV	Vietna	1
    ABC	Albania	1
    Sport TV	Brasil	1
    SuperSport	Africa do Sul	1
    Rede Bandeirantes	Brasil	1
    SIC	Portugal	1

    As alterações não foram refletidas após o commit na sessão 1.
    
    No modo de isolamento SERIALIZABLE, uma transação opera em um ambiente
    que simula um cenário em que não há alterações feitas por outros usuários.
    Logo, qualquer dado lido será o mesmo durante toda a transação
    
    Sendo assim, neste cenário, as modificações na sessão 1 só serão
    visualizáveis na sessão 2 após o término de sua transação.
*/
-- ix -- * Sessão 2
COMMIT;
/*
    Output: Commit concluído.
*/
-- x -- * Sessão 2
SELECT E.NOME, E.PAIS, COUNT(PT.PAISTRANSM) FROM EMISSORA E
    LEFT JOIN PAISTRANSM PT ON E.NOME = PT.NOMEEMISSORA AND E.PAIS = PT.PAISEMISSORA
    GROUP BY E.NOME, E.PAIS;
/*
    Resultado:
    Broadcasting Organization of Nigeria	Nigeria	6
    Televisa	Mexico	1
    Radio Nacional	Argentina	1
    Venevision	Venezuela	1
    BBC	Inglaterra	3
    CBC	Canada	1
    Canal 7	Argentina	1
    Cuatro	Espanha	1
    NTV	Nova Zelandia	1
    RDP Antena 1	Portugal	1
    RTP	Portugal	1
    RTSH	Albania	1
    TF1	Franca	1
    Rede Globo	Brasil	0
    ESPN Brasil	Brasil	1
    ESPN360	Estados Unidos	1
    RAI	Italia	1
    Sport TV	Portugal	1
    VTV	Vietna	1
    ABC	Albania	1
    Sport TV	Brasil	1
    SuperSport	Africa do Sul	1
    Rede Bandeirantes	Brasil	1
    SIC	Portugal	1

    As alterações foram refletidas na sessão 2 apenas quando houve o commit
    pela sessão 2.
    
    Com o commit na transação SERIALIZABLE na sessão 2, os dados modificados
    pela sessão 1 passam a ser vistos pela sessão 2, assim como explicado
    anteriormente, no passo 8.
*/

-- Exercício 2a ---------------------------------------------------------------
/*
    Como orientado externamente (Tidia), será criado um trigger para operações
    DML somente sobre uma tabela do esquema.
*/
/*
    Criando tabela de Log
*/
CREATE TABLE DML_LOG (
    usuario VARCHAR2(255),
    DATAHORA DATE,
    OPERACAO VARCHAR2(255),
    TIPO_OBJETO VARCHAR2(255),
    NOME_OBJETO VARCHAR2(255)
);

/*
    Criando Trigger sobre operações DML para a tabela JOGO
*/
CREATE OR REPLACE TRIGGER DML_JOGO
AFTER INSERT OR UPDATE OR DELETE ON JOGO
BEGIN
    IF INSERTING THEN
        INSERT INTO DML_LOG VALUES(USER, SYSDATE, 'INSERT', 'TABLE', 'JOGO');
    ELSIF UPDATING THEN
        INSERT INTO DML_LOG VALUES(USER, SYSDATE, 'UPDATE', 'TABLE', 'JOGO');
    ELSIF DELETING THEN
        INSERT INTO DML_LOG VALUES(USER, SYSDATE, 'DELETE', 'TABLE', 'JOGO');
    END IF;
END;

/*
    Testando funcionamento do trigger com operações DML
*/
-- Inserindo uma tupla
INSERT INTO JOGO VALUES (870, 'Primeira Fase', 'Africa do Sul', 'Mexico',
    SYSDATE, 1, 0, 'Estadio Soccer City', 'Zé1', 'Zé2', 'Zé3', 'Zé4');
-- Atualizando uma tupla
UPDATE JOGO SET NGOLS2=1 WHERE NUMERO=870;
-- Deletando uma tupla
DELETE FROM JOGO WHERE NUMERO=870;

COMMIT;

-- Verificando conteúdo de DML_LOG
SELECT L.* FROM DML_LOG L;
/*
    Resultado:
    USUARIO DATAHORA    OPERACAO    TIPO_OBJETO NOME_OBJETO
    A9778985	22/06/19	INSERT	TABLE	JOGO
    A9778985	22/06/19	UPDATE	TABLE	JOGO
    A9778985	22/06/19	DELETE	TABLE	JOGO
    
    É possível verificar o funcionamento correto do trigger, com uma tupla
    na tabela DML_LOG por operação DML.
*/

-- Exercício 2b ---------------------------------------------------------------
/*
    Iniciando uma nova transação
*/

-- Transação com COMMIT
-- Removendo tuplas anteriores para melhorar visualização do output
DELETE FROM DML_LOG;
COMMIT;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN
    -- Realizando operações sobre a tabela JOGO
    -- Inserindo uma tupla
    INSERT INTO JOGO VALUES (870, 'Primeira Fase', 'Africa do Sul', 'Mexico',
        SYSDATE, 1, 0, 'Estadio Soccer City', 'Zé1', 'Zé2', 'Zé3', 'Zé4');
    -- Atualizando uma tupla
    UPDATE JOGO SET NGOLS2=1 WHERE NUMERO=870;
    -- Deletando uma tupla
    DELETE FROM JOGO WHERE NUMERO=870;
    
    COMMIT;
END;

SELECT L.* FROM DML_LOG L;
/*
    Resultado:
    USUARIO DATAHORA    OPERACAO    TIPO_OBJETO NOME_OBJETO
    A9778985	22/06/19	INSERT	TABLE	JOGO
    A9778985	22/06/19	UPDATE	TABLE	JOGO
    A9778985	22/06/19	DELETE	TABLE	JOGO
*/

-- Transação com ROLLBACK
-- Removendo tuplas anteriores para melhorar visualização do output
DELETE FROM DML_LOG;
COMMIT;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN
    -- Realizando operações sobre a tabela JOGO
    -- Inserindo uma tupla
    INSERT INTO JOGO VALUES (870, 'Primeira Fase', 'Africa do Sul', 'Mexico',
        SYSDATE, 1, 0, 'Estadio Soccer City', 'Zé1', 'Zé2', 'Zé3', 'Zé4');
    -- Atualizando uma tupla
    UPDATE JOGO SET NGOLS2=1 WHERE NUMERO=870;
    -- Deletando uma tupla
    DELETE FROM JOGO WHERE NUMERO=870;
    
    ROLLBACK;
END;

SELECT L.* FROM DML_LOG L;
/*
    Resultado (nenhuma tupla)
    USUARIO DATAHORA    OPERACAO    TIPO_OBJETO NOME_OBJETO
*/

/*
    Obtivemos o resultado esperado. Com o rollback, as operações do trigger
    também foram revertidas.
*/

-- Exercício 2c ---------------------------------------------------------------
/*
    Esse cenário é possível com a criação de um trigger que executa a inserção
    antes da operação de DML, como uma transação autônoma.

    Recriando o trigger:
*/

CREATE OR REPLACE TRIGGER DML_JOGO
BEFORE INSERT OR UPDATE OR DELETE ON JOGO
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION; -- Iniciando uma transação autônoma
BEGIN
    IF INSERTING THEN
        INSERT INTO DML_LOG VALUES(USER, SYSDATE, 'INSERT', 'TABLE', 'JOGO');
    ELSIF UPDATING THEN
        INSERT INTO DML_LOG VALUES(USER, SYSDATE, 'UPDATE', 'TABLE', 'JOGO');
    ELSIF DELETING THEN
        INSERT INTO DML_LOG VALUES(USER, SYSDATE, 'DELETE', 'TABLE', 'JOGO');
    END IF;

    COMMIT; -- Tornando permanente a inserção na tabela de LOG.
END;

/*
    Testando o funcionamento com uma transação com ROLLBACK
*/
-- Removendo tuplas anteriores para melhorar visualização do output
DELETE FROM DML_LOG;
COMMIT;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN
    -- Realizando operações sobre a tabela JOGO
    -- Inserindo uma tupla
    INSERT INTO JOGO VALUES (870, 'Primeira Fase', 'Africa do Sul', 'Mexico',
        SYSDATE, 1, 0, 'Estadio Soccer City', 'Zé1', 'Zé2', 'Zé3', 'Zé4');
    -- Atualizando uma tupla
    UPDATE JOGO SET NGOLS2=1 WHERE NUMERO=870;
    -- Deletando uma tupla
    DELETE FROM JOGO WHERE NUMERO=870;
    
    ROLLBACK;
END;

SELECT L.* FROM DML_LOG L;
/*
    Resultado (nenhuma tupla)
    USUARIO DATAHORA    OPERACAO    TIPO_OBJETO NOME_OBJETO
    A9778985	22/06/19	INSERT	TABLE	JOGO
    A9778985	22/06/19	UPDATE	TABLE	JOGO
    A9778985	22/06/19	DELETE	TABLE	JOGO

    Como esperado, apesar da transação-pai ter executado o rollback, revertendo
    suas alterações, o trigger ainda foi executado como uma transação autônoma,
    inserindo as operações no LOG e as tornando permanentes.
*/

-- Exercício 3 ----------------------------------------------------------------
/*
    Criando uma transação que, para cada time do grupo G:
        Insere um novo hotel na base de dados;
        Insere uma delegação na tabela HOSPEDA em um determinado hotel;
        Cria uma nova hospedagem de uma semana, inserindo uma tupla na tabela
        PERIODOHOSP, com o SYSDATE atual.
*/

-- Para esta transação, o nível de isolamento READ COMMITTED é suficiente.
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
DECLARE
    TYPE t_paises IS TABLE OF TIME.PAIS%TYPE INDEX BY PLS_INTEGER;
    TYPE t_ndelegacoes IS VARRAY(4) OF HOSPEDA.NDELEGACAO%TYPE;
    v_paises t_paises;
    v_grupo TIME.GRUPO%TYPE;
    v_hotel HOTEL.NOME%TYPE;
    v_cidade HOTEL.CIDADE%TYPE;
    v_ndelegacoes t_ndelegacoes := t_ndelegacoes(0, 0, 0, 0);
    e_teamnumber EXCEPTION;
BEGIN
    -- Simulando input de usuário
    v_grupo := 'G';
    v_hotel := 'Paris Hotel';
    v_cidade := 'Paris';
    v_ndelegacoes(1):= 25;
    v_ndelegacoes(2):= 30;
    v_ndelegacoes(3):= 35;
    v_ndelegacoes(4):= 40;

    -- Tentar inserir dados na tabela HOTEL
    BEGIN
        INSERT INTO HOTEL VALUES (v_hotel, v_cidade);
        EXCEPTION WHEN dup_val_on_index THEN
            NULL; -- Se já existe, não fazer nada
    END;
    SAVEPOINT hotel_inserido; -- Savepoint para salvar os dados do hotel

    -- Coletando tuplas dos paises do grupo v_grupo para a coleção
    SELECT T.PAIS BULK COLLECT INTO v_paises FROM TIME T
        WHERE T.GRUPO = v_grupo;
    -- Verifica se existem 4 países no grupo
    IF v_paises.COUNT <> 4 THEN
        RAISE e_teamnumber;
    END IF;

    -- Para cada pais, insere uma delegação nova na tabela HOSPEDA, e
    -- insere uma tupla na tabela PERIODOHOSP
    FOR i IN v_paises.FIRST .. v_paises.LAST LOOP
        SAVEPOINT inserir_time; -- Criar savepoint antes de cada inserção
        INSERT INTO HOSPEDA VALUES (v_paises(i), v_hotel, v_ndelegacoes(i));
        INSERT INTO PERIODOHOSP VALUES (v_paises(i), v_hotel, SYSDATE,
            SYSDATE + 7);
    END LOOP;
    
    COMMIT; -- Se todas as tuplas foram inseridas com sucesso, COMMIT
    EXCEPTION
        WHEN SUBSCRIPT_BEYOND_COUNT THEN
            DBMS_OUTPUT.PUT_LINE('Acesso indevido à uma coleção (elemento fora dos limites).');
            ROLLBACK;
		WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Tentativa de acesso a elemento sem atribuição');
            ROLLBACK;
		WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Tentativa de acesso a um elemento fora do intervalo do tipo de dados PLS_INTEGER.');
            ROLLBACK;
        WHEN e_teamnumber THEN
            -- Voltar para ponto de inserção do HOTEL e efetuar inserção.
            DBMS_OUTPUT.PUT_LINE('Número incorreto de times para o grupo '
                || v_grupo);
            ROLLBACK TO hotel_inserido;
            COMMIT;
        WHEN dup_val_on_index THEN
            -- Voltar para ponto anterior à ultima inserção no loop e efetuar inserções anteriores
            DBMS_OUTPUT.PUT_LINE('Tentativa de inserção de tupla duplicada em HOSPEDA ou PERIODOHOSP.');
            ROLLBACK TO inserir_time;
            COMMIT;
        WHEN OTHERS THEN
            -- Voltar para ponto anterior à ultima inserção no loop e efetuar inserções anteriores
            DBMS_OUTPUT.PUT_LINE('ERRO NRO: ' || SQLCODE || '; MENSAGEM: ' ||
                SQLERRM);
            ROLLBACK TO inserir_time;
            COMMIT;
END;

/*
    Ao final da transação, as seguintes novas tuplas são inseridas:
    TABELA HOTEL:
        NOME    CIDADE
        Paris Hotel	Paris
    TABELA HOSPEDA
        TIME    HOTEL   NDELEGACAO
        Brasil	Paris Hotel	25
        Coreia do Norte	Paris Hotel	30
        Costa do Marfim	Paris Hotel	35
        Portugal	Paris Hotel	40
    TABELA PERIODOHOSP
        TIME    HOTEL   DTAENTRADA  DTASAIDA
        Brasil	Paris Hotel	22/06/19	29/06/19
        Coreia do Norte	Paris Hotel	22/06/19	29/06/19
        Costa do Marfim	Paris Hotel	22/06/19	29/06/19
        Portugal	Paris Hotel	22/06/19	29/06/19

    Para os possíveis errros, houve o seu devido tratamento.
*/
