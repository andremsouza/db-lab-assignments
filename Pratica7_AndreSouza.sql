/*
    Nome: André Moreira Souza    N°USP: 9778985
    Prática 7 - PL/SQL
*/
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS'; -- para mudar a forma de representação das datas
-- Exercício 1 --------------------------------------------------------------------------------------------------------
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
    e_nostadium EXCEPTION;
BEGIN
    OPEN c1;
    FETCH c1 INTO v1;
    IF c1%NOTFOUND THEN
        RAISE e_nostadium;
    END IF;
    DBMS_OUTPUT.PUT_LINE('ESTADIO' || chr(9) || '|' || chr(9) || 'CIDADE');
    WHILE c1%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE(v1.estadio || chr(9) || '|' || chr(9) || v1.cidade);
        FETCH c1 INTO v1;
    END LOOP;
    CLOSE c1;
    EXCEPTION
    WHEN e_nostadium
        THEN DBMS_OUTPUT.PUT_LINE('Não existem estádios'); ROLLBACK;
    WHEN OTHERS
        THEN DBMS_OUTPUT.PUT_LINE('ERRO NRO: ' || SQLCODE || '; MENSAGEM: ' || SQLERRM); ROLLBACK;
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
        Quando não existem estádios, haverá um erro ("Não existem estádios').
*/

-- Exercício 2a -------------------------------------------------------------------------------------------------------
DECLARE
    CURSOR c1 IS SELECT J.NUMERO FROM JOGO J WHERE UPPER(TIME1) = 'BRASIL' OR UPPER(TIME2) = 'BRASIL';
    v1 c1%ROWTYPE;
    e_nogames EXCEPTION;
BEGIN
    OPEN c1;
    FETCH c1 INTO v1;
    IF c1%NOTFOUND THEN
        RAISE e_nogames;
    END IF;
    DBMS_OUTPUT.PUT_LINE('NUMERO');
    LOOP
        DBMS_OUTPUT.PUT_LINE(v1.numero);
        UPDATE JOGO J SET J.DATAHORA = J.DATAHORA + ((1/24)*2) WHERE J.NUMERO = v1.numero;
        FETCH c1 INTO v1;
        EXIT WHEN c1%NOTFOUND;
    END LOOP;
    CLOSE c1;
    COMMIT;
    EXCEPTION
    WHEN e_nogames
        THEN DBMS_OUTPUT.PUT_LINE('Não existem jogos do Brasil'); ROLLBACK;
    WHEN OTHERS
        THEN DBMS_OUTPUT.PUT_LINE('ERRO NRO: ' || SQLCODE || '; MENSAGEM: ' || SQLERRM); ROLLBACK;
END;

/*
    Output para a base inicial (números dos jogos em que é realizado o UPDATE):
    NUMERO
    64
    79
    95

    Quando não existem jogos do Brasil, há uma mensagem de exceção ('Não existem jogos do Brasil')
*/

-- Exercício 2b -------------------------------------------------------------------------------------------------------
DECLARE
    CURSOR c1 IS SELECT ROWID FROM JOGO J WHERE UPPER(TIME1) = 'BRASIL' OR UPPER(TIME2) = 'BRASIL' FOR UPDATE OF J.DATAHORA;
    v1 c1%ROWTYPE;
    e_nogames EXCEPTION;
BEGIN
    OPEN c1;
    FETCH c1 INTO v1;
    IF c1%NOTFOUND THEN
        RAISE e_nogames;
    END IF;
    DBMS_OUTPUT.PUT_LINE('ROWID');
    WHILE c1%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE(v1.ROWID);
        UPDATE JOGO J SET J.DATAHORA = J.DATAHORA + ((1/24)*2) WHERE CURRENT OF c1;
        FETCH c1 INTO v1;
    END LOOP;
    CLOSE c1;
    COMMIT;
    EXCEPTION
    WHEN e_nogames
        THEN DBMS_OUTPUT.PUT_LINE('Não existem jogos do Brasil'); ROLLBACK;
    WHEN OTHERS
        THEN DBMS_OUTPUT.PUT_LINE('ERRO NRO: ' || SQLCODE || '; MENSAGEM: ' || SQLERRM); ROLLBACK;
END;
/*
    Output para a base inicial:
    ROWID
    AAC2VwAAEAAEaVXAAN
    AAC2VwAAEAAEaVXAAc
    AAC2VwAAEAAEaVXAAs
    
    Foi tratado o caso de erro onde não existem jogos do Brasil.
*/

/*
    Analisando o aspecto de consistência durante a execução, ambas as versões são capazes de atualizar a tupla correta mas, na versão do exercício 2a, é possível que as tuplas em questão sejam atualizadas por outras entidades durante a execução, o que pode gerar inconsistências.
    A presença da keyword FOR UPDATE garante que, enquanto o cursor estiver aberto, as tuplas selecionadas estejam bloqueadas para UPDATE / DELETE de outros processos.
    É interessante notar que, devido à keyword CURRENT OF, não é necessária a presença da chave da tabela JOGO na segunda versão do programa, pois a atualização é realizada sobre a última tupla retornada pelo cursor, utilizando o ROWID.
    Em termos de performance, ambas os programas em PL/SQL são similares, onde a segunda versão pode causar um desempenho ligeiramente pior, devido ao bloqueio das tuplas, interferindo em outras transações. Ambos os programas têm um desempenho pior do que uma consulta em SQL puro.
*/

-- Exercício 3 --------------------------------------------------------------------------------------------------------

/*
    Inserindo dados para verificar funcionamento do programa
*/
INSERT INTO JOGO VALUES (866, 'Oitavas-de-Final', 'Brasil', 'Portugal', TO_DATE('27/06/2022 20:30:00', 'DD/MM/YYYY HH24:MI:SS'), 0, 0, 'Estadio Moses Mabhida', 'AR1', 'AR2', 'AR3', 'AR4');
INSERT INTO JOGO VALUES (867, 'Oitavas-de-Final', 'Holanda', 'Brasil', TO_DATE('28/06/2022 16:00:00', 'DD/MM/YYYY HH24:MI:SS'), 2, 1, 'Estadio Ellis Park', 'AR1', 'AR2', 'AR3', 'AR4');
INSERT INTO PARTICIPA VALUES (866, 866, TO_DATE('27/06/2022 20:30:00', 'DD/MM/YYYY HH24:MI:SS'), TO_DATE('27/06/2022 22:00:00', 'DD/MM/YYYY HH24:MI:SS'), 0, 0, 0, 0, 0, 'Titular');
INSERT INTO PARTICIPA VALUES (866, 867, TO_DATE('27/06/2022 16:00:00', 'DD/MM/YYYY HH24:MI:SS'), TO_DATE('27/06/2022 17:30:00', 'DD/MM/YYYY HH24:MI:SS'), 0, 0, 0, 1, 1, 'Titular');
COMMIT;

DECLARE
    v_nfifa PARTICIPA.JOGADOR%TYPE;
    v_nome JOGADOR.NOME%TYPE;
    v_dtanasc JOGADOR.DTANASC%TYPE;
    v_qtdpart NUMBER;
    e_nopart EXCEPTION;
BEGIN
    v_nfifa := 866; -- Testando com um nfifa específico.
    SELECT J.NOME, J.DTANASC INTO v_nome, v_dtanasc FROM JOGADOR J WHERE J.NFIFA = v_nfifa;
    DELETE FROM PARTICIPA P WHERE P.JOGADOR = v_nfifa AND P.JOGO IN (SELECT J.NUMERO FROM JOGO J WHERE UPPER(J.FASE) = 'OITAVAS-DE-FINAL');
    v_qtdpart := SQL%ROWCOUNT;
    IF v_qtdpart = 0 THEN
        RAISE e_nopart;
    END IF;
    DBMS_OUTPUT.PUT_LINE('NOME' || chr(9) || chr(9) || 'DTANASC' || chr(9) || chr(9) || 'Linhas removidas');
    DBMS_OUTPUT.PUT_LINE(v_nome || chr(9) || chr(9) || v_dtanasc || chr(9) || chr(9) || v_qtdpart);
    COMMIT;
    EXCEPTION
    WHEN e_nopart THEN
        DBMS_OUTPUT.PUT_LINE('Não existem participações para o jogador com o NFIFA = ' || v_nfifa); ROLLBACK;
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Não existe um jogador com o NFIFA = ' || v_nfifa); ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERRO NRO: ' || SQLCODE || '; MENSAGEM: ' || SQLERRM); ROLLBACK;
END;

/*
    Com a inserção das novas tuplas, o resultado do programa deve ser como a seguir:
    NOME		DTANASC		Linhas removidas
    Robson de Souza		25-01-1984 00:00:00		2
    
    Foram tratadas exceções caso não exista o jogador ou participações deste.
*/