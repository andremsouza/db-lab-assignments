/*
	Nome: André Moreira Souza    N°USP: 9778985
	Prática 12 - Transações
*/

-- Exercício 1 ----------------------------------------------------------------

-- Utilizando nível de isolamento READ COMMITED -------------------------------

-- i -> conexão aberta.
-- ii -> 2ª conexão aberta.
-- iii -- ? Sessão 2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
/*
    Saída: Transaction ISOLATION bem-sucedido.
*/
-- iv -- ? Sessão 2
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
-- v -- ? Sessão 1
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
-- vi -- ? Sessão 2
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
    
    Percebe-se que a contagem de países de transmissão para a emissora 'Rede Globo' permaneceu o mesmo, mesmo após a remoção da
        tupla na sessão 1.
    -- ! Por que?
*/
-- vii -- ? Sessão 1
COMMIT;
/*
    Output: Commit concluído
*/
-- viii -- ? Sessão 2
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

    A remoção na sessão 1 foi refletida na consulta da sessão 2
    -- ! Por que?
*/
-- ix -- ? Sessão 2
COMMIT;
/*
    Output: Commit concluído.
*/
-- x -- ? Sessão 2
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
    -- ! Por que?
*/

-- Utilizando nível de isolamento SERIALIZABLE --------------------------------

-- i -> conexão aberta.
-- ii -> 2ª conexão aberta.
-- iii -- ? Sessão 2
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
/*
    Output: Transaction ISOLATION bem-sucedido.
*/
-- iv -- ? Sessão 2
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
-- v -- ? Sessão 1
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
-- vi -- ? Sessão 2
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
    -- ! Por que?
*/
-- vii -- ? Sessão 1
COMMIT;
/*
    Output: Commit Concluído.
*/
-- viii -- ? Sessão 2
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
    -- ! Por que?
*/
-- ix -- ? Sessão 2
COMMIT;
/*
    Output: Commit concluído.
*/
-- x -- ? Sessão 2
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
        por esta sessão.
    -- ! Por que?
*/

-- Exercício 2 ----------------------------------------------------------------

-- 2a -------------------------------------------------------------------------
