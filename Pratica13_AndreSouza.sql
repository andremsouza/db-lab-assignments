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
*/

CREATE OR REPLACE TYPE Time_objtyp AS OBJECT (
    pais VARCHAR2(100),
    nfifa NUMBER,
    bandeira BLOB,
    tecnico VARCHAR2(100)
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
    time REF Time_objtyp -- Referenciando objeto Time existente
);
/*
    Criando e populando tabela de objetos Time_objtyp
*/
CREATE TABLE TIME_OR OF Time_objtyp;
INSERT INTO TIME_OR VALUES ('Africa do Sul'  ,  1, EMPTY_BLOB(), 'Carlos Alberto Parreira'     );
INSERT INTO TIME_OR VALUES ('Mexico'         ,  2, EMPTY_BLOB(), 'Javier Aguirre'              );
INSERT INTO TIME_OR VALUES ('Uruguai'        ,  3, EMPTY_BLOB(), 'Oscar Tabarez'               );
INSERT INTO TIME_OR VALUES ('Franca'         ,  4, EMPTY_BLOB(), 'Raymond Domenech'            );
INSERT INTO TIME_OR VALUES ('Argentina'      ,  5, EMPTY_BLOB(), 'Diego Armando Maradona'      );
INSERT INTO TIME_OR VALUES ('Nigeria'        ,  6, EMPTY_BLOB(), 'Shaibu Amodu'                );
INSERT INTO TIME_OR VALUES ('Coreia do Sul'  ,  7, EMPTY_BLOB(), 'Huh Jung-Moo'                );
INSERT INTO TIME_OR VALUES ('Grecia'         ,  8, EMPTY_BLOB(), 'Otto Rehhagel'               );
INSERT INTO TIME_OR VALUES ('Inglaterra'     ,  9, EMPTY_BLOB(), 'Fabio Capello'               );
INSERT INTO TIME_OR VALUES ('Estados Unidos' , 10, EMPTY_BLOB(), 'Bob Bradley'                 );
INSERT INTO TIME_OR VALUES ('Argelia'        , 11, EMPTY_BLOB(), 'Rabah Saadane'               );
INSERT INTO TIME_OR VALUES ('Eslovenia'      , 12, EMPTY_BLOB(), 'Matjaz Kek'                  );
INSERT INTO TIME_OR VALUES ('Alemanha'       , 13, EMPTY_BLOB(), 'Joachim Low'                 );
INSERT INTO TIME_OR VALUES ('Australia'      , 14, EMPTY_BLOB(), 'Pim Verbeek'                 );
INSERT INTO TIME_OR VALUES ('Servia'         , 15, EMPTY_BLOB(), 'Radomir Antic'               );
INSERT INTO TIME_OR VALUES ('Gana'           , 16, EMPTY_BLOB(), 'Milovan Rajevac'             );
INSERT INTO TIME_OR VALUES ('Holanda'        , 17, EMPTY_BLOB(), 'Van Marwijk'                 );
INSERT INTO TIME_OR VALUES ('Dinamarca'      , 18, EMPTY_BLOB(), 'Morten Olsen'                );
INSERT INTO TIME_OR VALUES ('Japao'          , 19, EMPTY_BLOB(), 'Takeshi Okada'               );
INSERT INTO TIME_OR VALUES ('Camaroes'       , 20, EMPTY_BLOB(), 'Paul Le Guen'                );
INSERT INTO TIME_OR VALUES ('Italia'         , 21, EMPTY_BLOB(), 'Marcello Lippi'              );
INSERT INTO TIME_OR VALUES ('Paraguai'       , 22, EMPTY_BLOB(), 'Gerardo Martino'             );
INSERT INTO TIME_OR VALUES ('Nova Zelandia'  , 23, EMPTY_BLOB(), 'Ricki Herbert'               );
INSERT INTO TIME_OR VALUES ('Eslovaquia'     , 24, EMPTY_BLOB(), 'Vladimir Weiss'              );
INSERT INTO TIME_OR VALUES ('Brasil'         , 25, EMPTY_BLOB(), 'Carlos Caetano Bledorn Verri');
INSERT INTO TIME_OR VALUES ('Coreia do Norte', 26, EMPTY_BLOB(), 'Kim Jong-Hun'                );
INSERT INTO TIME_OR VALUES ('Costa do Marfim', 27, EMPTY_BLOB(), 'Vahid Halilhodzic'           );
INSERT INTO TIME_OR VALUES ('Portugal'       , 28, EMPTY_BLOB(), 'Carloz Queiroz'              );
INSERT INTO TIME_OR VALUES ('Espanha'        , 29, EMPTY_BLOB(), 'Vicente del Bosque'          );
INSERT INTO TIME_OR VALUES ('Suica'          , 30, EMPTY_BLOB(), 'Ottmar Hitzfeld'             );
INSERT INTO TIME_OR VALUES ('Honduras'       , 31, EMPTY_BLOB(), 'Reinaldo Rueda'              );
INSERT INTO TIME_OR VALUES ('Chile'          , 32, EMPTY_BLOB(), 'Marcelo Bielsa'              );
/*
    Criando e populando tabela de jogadores Jogador_objtyp
    Para propósitos de teste, estarei inserindo apenas jogadores
    do time 'Brasil'
*/
CREATE TABLE JOGADOR_OR OF Jogador_objtyp(
    time SCOPE IS TIME_OR
) NESTED TABLE clubes STORE AS tbl_clubes;
INSERT INTO JOGADOR_OR values ( 1, 'Adriano Leite Ribeiro'           , 'Adriano'       , to_date('17/02/1982','dd/mm/yyyy'), 'Atacante'  , 'N', 'Brasil');
INSERT INTO JOGADOR_OR values ( 2, 'Daniel Alves da Silva'           , 'Daniel Alves'  , to_date('06/05/1983','dd/mm/yyyy'), 'Meio Campo', 'N', 'Brasil');
INSERT INTO JOGADOR_OR values ( 3, 'Donieber Alexander Marangon'     , 'Doni'          , to_date('22/10/1979','dd/mm/yyyy'), 'Goleiro'   , 'N', 'Brasil');
INSERT INTO JOGADOR_OR values ( 4, 'Elano Blumer'                    , 'Elano'         , to_date('14/06/1981','dd/mm/yyyy'), 'Meio Campo', 'N', 'Brasil');
INSERT INTO JOGADOR_OR values ( 5, 'Felipe Melo de Carvalho'         , 'Felipe Melo'   , to_date('26/06/1983','dd/mm/yyyy'), 'Meio Campo', 'N', 'Brasil');
INSERT INTO JOGADOR_OR values ( 6, 'Gilberto da Silva Melo'          , 'Gilberto'      , to_date('25/04/1976','dd/mm/yyyy'), 'Zagueiro'  , 'N', 'Brasil');
INSERT INTO JOGADOR_OR values ( 7, 'Gilberto Aparecido da Silva'     , 'Gilberto Silva', to_date('07/10/1976','dd/mm/yyyy'), 'Meio Campo', 'N', 'Brasil');
INSERT INTO JOGADOR_OR values ( 8, 'Josue Anunciado de Oliveira'     , 'Josue'         , to_date('19/07/1979','dd/mm/yyyy'), 'Meio Campo', 'N', 'Brasil');
INSERT INTO JOGADOR_OR values ( 9, 'Juan Silveira dos Santos'        , 'Juan'          , to_date('01/02/1979','dd/mm/yyyy'), 'Zagueiro'  , 'N', 'Brasil');
INSERT INTO JOGADOR_OR values (10, 'Julio Cesar Baptista'            , 'Julio Baptista', to_date('01/10/1981','dd/mm/yyyy'), 'Meio Campo', 'N', 'Brasil');
INSERT INTO JOGADOR_OR values (11, 'Julio Cesar Soares de Espindola' , 'Julio Cesar'   , to_date('03/09/1979','dd/mm/yyyy'), 'Goleiro'   , 'N', 'Brasil');
INSERT INTO JOGADOR_OR values (12, 'Ricardo Izecson dos Santos Leite', 'Kaka'          , to_date('22/04/1982','dd/mm/yyyy'), 'Meio Campo', 'N', 'Brasil');
INSERT INTO JOGADOR_OR values (13, 'Jose Kleberson Pereira'          , 'Kleberson'     , to_date('19/06/1979','dd/mm/yyyy'), 'Meio Campo', 'N', 'Brasil');
INSERT INTO JOGADOR_OR values (14, 'Lucimar da Silva Ferreira'       , 'Lucio'         , to_date('08/05/1978','dd/mm/yyyy'), 'Zagueiro'  , 'S', 'Brasil');
INSERT INTO JOGADOR_OR values (15, 'Luis Fabiano Clemente'           , 'Luis Fabiano'  , to_date('08/11/1980','dd/mm/yyyy'), 'Atacante'  , 'N', 'Brasil');
INSERT INTO JOGADOR_OR values (16, 'Anderson Luis da Silva'          , 'Luisao'        , to_date('13/02/1981','dd/mm/yyyy'), 'Zagueiro'  , 'N', 'Brasil');
INSERT INTO JOGADOR_OR values (17, 'Maicon Douglas Sisenando'        , 'Maicon'        , to_date('26/07/1981','dd/mm/yyyy'), 'Meio Campo', 'N', 'Brasil');
INSERT INTO JOGADOR_OR values (18, 'Michel Fernandes Bastos'         , 'Michel Bastos' , to_date('02/08/1983','dd/mm/yyyy'), 'Meio Campo', 'N', 'Brasil');
INSERT INTO JOGADOR_OR values (19, 'Nilmar Honorato da Silva'        , 'Nilmar'        , to_date('14/07/1984','dd/mm/yyyy'), 'Atacante'  , 'N', 'Brasil');
INSERT INTO JOGADOR_OR values (20, 'Ramires Santos do Nascimento'    , 'Ramires'       , to_date('24/03/1987','dd/mm/yyyy'), 'Meio Campo', 'N', 'Brasil');
INSERT INTO JOGADOR_OR values (21, 'Robson de Souza'                 , 'Robinho'       , to_date('25/01/1984','dd/mm/yyyy'), 'Atacante'  , 'N', 'Brasil');
INSERT INTO JOGADOR_OR values (22, 'Thiago Emiliano da Silva'        , 'Thiago Silva'  , to_date('22/09/1984','dd/mm/yyyy'), 'Zagueiro'  , 'N', 'Brasil');