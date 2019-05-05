/*
    Nome: André Moreira Souza    N°USP: 9778985
    Prática 7 - PL/SQL
*/

-- Exercício 1 --------------------------------------------------------------------------------------------------------
--ALTER SESSION SET PLSQL_WARNINGS='ENABLE:ALL';
DECLARE
  CURSOR c1 IS
        SELECT E.NOME ESTADIO, E.CIDADE CIDADE FROM ESTADIO E
            LEFT JOIN JOGO J ON J.ESTADIO = E.NOME
            GROUP BY E.NOME, E.CIDADE
            HAVING COUNT(J.NUMERO) =
                (SELECT MAX(A.CNT) MAXCNT FROM 
                    (SELECT COUNT(JOGO.NUMERO) CNT FROM ESTADIO ESTADIO 
                        LEFT JOIN JOGO JOGO ON JOGO.ESTADIO = ESTADIO.NOME 
                        GROUP BY ESTADIO.NOME) A);
    v1 c1%ROWTYPE;
BEGIN
    OPEN c1;
    DBMS_OUTPUT.PUT_LINE('ESTADIO' || chr(9) || '|' || chr(9) || 'CIDADE');
    LOOP
        FETCH c1 INTO v1;
        EXIT WHEN c1%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v1.estadio || chr(9) || '|' || chr(9) || v1.cidade);
    END LOOP;
    EXCEPTION
    WHEN OTHERS 
        THEN DBMS_OUTPUT.PUT_LINE('ERRO NRO: ' || SQLCODE || '; MENSAGEM: ' || SQLERRM);
END;

/*
    Resultado, com os dados iniciais da base de dados (máximo de contagem de jogos = 5):
    ESTADIO	|	CIDADE
    Estadio Moses Mabhida	|	Durban
    Estadio Green Point	|	Cidade do Cabo
    Estadio Nelson Mandela Bay	|	Nelson Mandela Bay/Port Elizabeth
    Estadio Royal Bafokeng	|	Rustemburgo
    Estadio Loftus Versfeld	|	Tshwane/Pretoria
    Estadio Free State	|	Mangaung/Bloemfontein
    Estadio Soccer City	|	Joanesburgo
    Estadio Ellis Park	|	Joanesburgo
    
    Obs.: Quando não existem estádios com jogos, todos os estádios serão exibidos (máximo de contagem de jogos = 0).
*/