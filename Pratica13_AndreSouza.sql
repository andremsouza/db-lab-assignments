/*
	Nome: André Moreira Souza    N°USP: 9778985
	Prática 13 - Objeto-Relacional
*/

-- Exercício 1 ----------------------------------------------------------------
/*
    A partir do DER - Copa do Mundo, modelando as entidades "TIME" e "JOGADOR",
    e o relacionamento "CONTÉM" entre estes.
    Além disso, adicionando uma lista de clubes para o objeto "JOGADOR", sendo
    esses os clubes em que tal jogador jogou anteriormente.

    Como orientado, será evitado o uso de recursos relacionais.
*/

CREATE OR REPLACE TYPE Time_objtyp AS OBJECT (
    pais VARCHAR2(100),
    nfifa NUMBER,
    bandeira BLOB,
    tecnico VARCHAR2(100)
    /*
    Foi omitido o atributo NTotalGols, devido à ausência do conjunto de jogos
    para esse esquema.
    */
);

CREATE OR REPLACE TYPE ClubeList_ntabtyp AS TABLE OF VARCHAR2(100);

CREATE OR REPLACE TYPE Jogador_objtyp AS OBJECT (
    nfifa NUMBER,
    nome VARCHAR2(100),
    apelido VARCHAR2(30),
    dtanasc DATE,
    posicao VARCHAR2(100),
    capitao CHAR(1), -- Possível candidato para método
    clubes ClubeList_ntabtyp,
    time REF Time_objtyp, -- Referenciando objeto Time existente
    
    -- Retorna a idade atual do jogador
    MEMBER FUNCTION get_idade RETURN NUMBER,
    -- Adiciona um novo clube para o jogador
    MEMBER PROCEDURE add_clube(new_clube IN VARCHAR2),
    -- Remove um clube do jogador, se existir na coleção
    MEMBER PROCEDURE remove_clube(clube IN VARCHAR2)
);
/
CREATE OR REPLACE TYPE BODY Jogador_objtyp IS
    MEMBER FUNCTION get_idade RETURN NUMBE IS
    -- Calcula a idade do jogador e a retorna.
    BEGIN
        RETURN (SYSDATE - dtanasc)/365;
    END get_idade;
    
    MEMBER PROCEDURE add_clube(new_clube IN VARCHAR2) AS
    -- Adiciona new_clube à coleção de clubes do jogador
    BEGIN
        -- TODO: PROCEDURE
    END;

    MEMBER PROCEDURE remove_clube(clube IN VARCHAR2) AS
    -- Remove um clube da coleção de clubes do jogador
    BEGIN
        -- TODO: PROCEDURE
    END;
END;
/*
    Criando e populando tabela de objetos Time_objtyp
*/
CREATE TABLE TIME_OR OF Time_objtyp;
INSERT INTO TIME_OR VALUES (Time_objtyp('Africa do Sul'  ,  1, EMPTY_BLOB(),'Carlos Alberto Parreira'     ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Mexico'         ,  2, EMPTY_BLOB(),'Javier Aguirre'              ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Uruguai'        ,  3, EMPTY_BLOB(),'Oscar Tabarez'               ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Franca'         ,  4, EMPTY_BLOB(),'Raymond Domenech'            ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Argentina'      ,  5, EMPTY_BLOB(),'Diego Armando Maradona'      ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Nigeria'        ,  6, EMPTY_BLOB(),'Shaibu Amodu'                ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Coreia do Sul'  ,  7, EMPTY_BLOB(),'Huh Jung-Moo'                ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Grecia'         ,  8, EMPTY_BLOB(),'Otto Rehhagel'               ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Inglaterra'     ,  9, EMPTY_BLOB(),'Fabio Capello'               ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Estados Unidos' , 10, EMPTY_BLOB(),'Bob Bradley'                 ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Argelia'        , 11, EMPTY_BLOB(),'Rabah Saadane'               ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Eslovenia'      , 12, EMPTY_BLOB(),'Matjaz Kek'                  ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Alemanha'       , 13, EMPTY_BLOB(),'Joachim Low'                 ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Australia'      , 14, EMPTY_BLOB(),'Pim Verbeek'                 ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Servia'         , 15, EMPTY_BLOB(),'Radomir Antic'               ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Gana'           , 16, EMPTY_BLOB(),'Milovan Rajevac'             ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Holanda'        , 17, EMPTY_BLOB(),'Van Marwijk'                 ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Dinamarca'      , 18, EMPTY_BLOB(),'Morten Olsen'                ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Japao'          , 19, EMPTY_BLOB(),'Takeshi Okada'               ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Camaroes'       , 20, EMPTY_BLOB(),'Paul Le Guen'                ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Italia'         , 21, EMPTY_BLOB(),'Marcello Lippi'              ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Paraguai'       , 22, EMPTY_BLOB(),'Gerardo Martino'             ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Nova Zelandia'  , 23, EMPTY_BLOB(),'Ricki Herbert'               ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Eslovaquia'     , 24, EMPTY_BLOB(),'Vladimir Weiss'              ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Brasil'         , 25, EMPTY_BLOB(),'Carlos Caetano Bledorn Verri'));
INSERT INTO TIME_OR VALUES (Time_objtyp('Coreia do Norte', 26, EMPTY_BLOB(),'Kim Jong-Hun'                ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Costa do Marfim', 27, EMPTY_BLOB(),'Vahid Halilhodzic'           ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Portugal'       , 28, EMPTY_BLOB(),'Carloz Queiroz'              ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Espanha'        , 29, EMPTY_BLOB(),'Vicente del Bosque'          ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Suica'          , 30, EMPTY_BLOB(),'Ottmar Hitzfeld'             ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Honduras'       , 31, EMPTY_BLOB(),'Reinaldo Rueda'              ));
INSERT INTO TIME_OR VALUES (Time_objtyp('Chile'          , 32, EMPTY_BLOB(),'Marcelo Bielsa'              ));
/*
    Criando e populando tabela de jogadores Jogador_objtyp. O atributo "clubes"
    referencia uma nova tabela tbl_clubes, aninhada à tabela JOGADOR_OR.
    Para propósitos de teste, estarei inserindo apenas jogadores
    do time 'Brasil', testando a inserção com atributos multivalorados (clube).
*/
CREATE TABLE JOGADOR_OR OF Jogador_objtyp(
    time SCOPE IS TIME_OR
) NESTED TABLE clubes STORE AS tbl_clubes;
INSERT INTO JOGADOR_OR values (Jogador_objtyp( 1, 'Adriano Leite Ribeiro'           , 'Adriano'       , to_date('17/02/1982','dd/mm/yyyy'), 'Atacante'  , 'N', ClubeList_ntabtyp('Flamengo'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp( 2, 'Daniel Alves da Silva'           , 'Daniel Alves'  , to_date('06/05/1983','dd/mm/yyyy'), 'Meio Campo', 'N', ClubeList_ntabtyp('Bahia'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp( 3, 'Donieber Alexander Marangon'     , 'Doni'          , to_date('22/10/1979','dd/mm/yyyy'), 'Goleiro'   , 'N', ClubeList_ntabtyp('Juventude'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp( 4, 'Elano Blumer'                    , 'Elano'         , to_date('14/06/1981','dd/mm/yyyy'), 'Meio Campo', 'N', ClubeList_ntabtyp('Santos'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp( 5, 'Felipe Melo de Carvalho'         , 'Felipe Melo'   , to_date('26/06/1983','dd/mm/yyyy'), 'Meio Campo', 'N', ClubeList_ntabtyp('Flamengo', 'Palmeiras'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp( 6, 'Gilberto da Silva Melo'          , 'Gilberto'      , to_date('25/04/1976','dd/mm/yyyy'), 'Zagueiro'  , 'N', ClubeList_ntabtyp('Flamengo'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp( 7, 'Gilberto Aparecido da Silva'     , 'Gilberto Silva', to_date('07/10/1976','dd/mm/yyyy'), 'Meio Campo', 'N', ClubeList_ntabtyp('América-MG'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp( 8, 'Josue Anunciado de Oliveira'     , 'Josue'         , to_date('19/07/1979','dd/mm/yyyy'), 'Meio Campo', 'N', ClubeList_ntabtyp('Goiás'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp( 9, 'Juan Silveira dos Santos'        , 'Juan'          , to_date('01/02/1979','dd/mm/yyyy'), 'Zagueiro'  , 'N', ClubeList_ntabtyp('Flamengo'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp(10, 'Julio Cesar Baptista'            , 'Julio Baptista', to_date('01/10/1981','dd/mm/yyyy'), 'Meio Campo', 'N', ClubeList_ntabtyp('São Paulo'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp(11, 'Julio Cesar Soares de Espindola' , 'Julio Cesar'   , to_date('03/09/1979','dd/mm/yyyy'), 'Goleiro'   , 'N', ClubeList_ntabtyp('Flamengo'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp(12, 'Ricardo Izecson dos Santos Leite', 'Kaka'          , to_date('22/04/1982','dd/mm/yyyy'), 'Meio Campo', 'N', ClubeList_ntabtyp('São Paulo'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp(13, 'Jose Kleberson Pereira'          , 'Kleberson'     , to_date('19/06/1979','dd/mm/yyyy'), 'Meio Campo', 'N', ClubeList_ntabtyp('Atlético-PR'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp(14, 'Lucimar da Silva Ferreira'       , 'Lucio'         , to_date('08/05/1978','dd/mm/yyyy'), 'Zagueiro'  , 'S', ClubeList_ntabtyp('Internacional'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp(15, 'Luis Fabiano Clemente'           , 'Luis Fabiano'  , to_date('08/11/1980','dd/mm/yyyy'), 'Atacante'  , 'N', ClubeList_ntabtyp('São Paulo'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp(16, 'Anderson Luis da Silva'          , 'Luisao'        , to_date('13/02/1981','dd/mm/yyyy'), 'Zagueiro'  , 'N', ClubeList_ntabtyp('Ceará'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp(17, 'Maicon Douglas Sisenando'        , 'Maicon'        , to_date('26/07/1981','dd/mm/yyyy'), 'Meio Campo', 'N', ClubeList_ntabtyp('Cruzeiro'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp(18, 'Michel Fernandes Bastos'         , 'Michel Bastos' , to_date('02/08/1983','dd/mm/yyyy'), 'Meio Campo', 'N', ClubeList_ntabtyp('Atlético-PR'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp(19, 'Nilmar Honorato da Silva'        , 'Nilmar'        , to_date('14/07/1984','dd/mm/yyyy'), 'Atacante'  , 'N', ClubeList_ntabtyp('Internacional'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp(20, 'Ramires Santos do Nascimento'    , 'Ramires'       , to_date('24/03/1987','dd/mm/yyyy'), 'Meio Campo', 'N', ClubeList_ntabtyp('Cruzeiro'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp(21, 'Robson de Souza'                 , 'Robinho'       , to_date('25/01/1984','dd/mm/yyyy'), 'Atacante'  , 'N', ClubeList_ntabtyp('Santos'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));
INSERT INTO JOGADOR_OR values (Jogador_objtyp(22, 'Thiago Emiliano da Silva'        , 'Thiago Silva'  , to_date('22/09/1984','dd/mm/yyyy'), 'Zagueiro'  , 'N', ClubeList_ntabtyp('Fluminense'), (SELECT REF(t) FROM TIME_OR t WHERE t.pais = 'Brasil')));