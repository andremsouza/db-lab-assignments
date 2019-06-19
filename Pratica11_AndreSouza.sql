/*
	Nome: André Moreira Souza    N°USP: 9778985
	Prática 11 - Triggers
*/

-- Exercício 1a ----------------------------------------------------------------
/*
    Criando dois triggers:
        Um para a atualização da pontuação, para jogos da primeira fase;
        Um para a atualização do número total de gols.
*/

CREATE OR REPLACE TRIGGER update_time_pontuacao
/*
    Trigger para inserção ou atualização de jogos.
    Atualiza a pontuação na tabela TIME, para cada jogo inserido, 
        atualizado ou removido.
    Apenas para jogos da primeira fase.
    Só realiza alterações quando os valores dos gols forem não-nulos.
    Obs.: Devido ao fato das colunas NGOLS1 e NGOLS2 serem nullable,
        foram necessárias verificações adicionais para cada caso na execução.
*/
AFTER INSERT OR UPDATE OR DELETE ON JOGO
FOR EACH ROW
BEGIN
    -- Se inserindo, ou atualizando quando tem valor anterior dos gols nulo
    -- Ou atualizando de um jogo de outra fase para a primeira fase
    IF ((INSERTING
            OR (UPDATING AND ((:OLD.NGOLS1 IS NULL OR :OLD.NGOLS2 IS NULL)
                                OR :OLD.FASE <> 'Primeira Fase'))
            )
            AND :NEW.FASE = 'Primeira Fase' AND :NEW.NGOLS1 IS NOT NULL 
            AND :NEW.NGOLS2 IS NOT NULL) THEN
        -- Update TIME1
        UPDATE TIME T
            SET T.PONTUACAO = (NVL(T.PONTUACAO, 0)
            + CASE WHEN :NEW.NGOLS1 > :NEW.NGOLS2 THEN 3
                WHEN :NEW.NGOLS1 = :NEW.NGOLS2 THEN 1
                WHEN :NEW.NGOLS2 > :NEW.NGOLS1 THEN 0
                ELSE NULL END -- Não deveria chegar neste caso (erro)
            )
        WHERE T.PAIS = :NEW.TIME1;
        
        -- Update TIME2
        UPDATE TIME T SET T.PONTUACAO = (NVL(T.PONTUACAO, 0)
            + CASE WHEN :NEW.NGOLS1 < :NEW.NGOLS2 THEN 3
                WHEN :NEW.NGOLS1 = :NEW.NGOLS2 THEN 1
                WHEN :NEW.NGOLS2 < :NEW.NGOLS1 THEN 0
                ELSE NULL END -- Não deveria chegar neste caso (erro)
            )
        WHERE T.PAIS = :NEW.TIME2;
    
    -- Se atualizando, verificar cada caso onde pode haver
    --  alteração na pontuação
    ELSIF (UPDATING AND :NEW.FASE = 'Primeira Fase'
            AND :NEW.NGOLS1 IS NOT NULL AND :NEW.NGOLS2 IS NOT NULL) THEN
        -- Update TIME1
        UPDATE TIME T SET T.PONTUACAO = (NVL(T.PONTUACAO, 0)
            + CASE WHEN -- Mantém mesmo resultado
                (:OLD.NGOLS1 > :OLD.NGOLS2 AND :NEW.NGOLS1 > :NEW.NGOLS2)
                OR (:OLD.NGOLS1 = :OLD.NGOLS2 AND:NEW.NGOLS1 = :NEW.NGOLS2)
                OR (:OLD.NGOLS2 > :OLD.NGOLS1 AND :NEW.NGOLS2 > :NEW.NGOLS1)
                    THEN 0
                WHEN -- Derrota -> Empate
                (:OLD.NGOLS2 > :OLD.NGOLS1 AND :NEW.NGOLS1 = :NEW.NGOLS2)
                    THEN 1
                WHEN -- Empate -> Vitória
                (:OLD.NGOLS1 = :OLD.NGOLS2 AND :NEW.NGOLS1 > :NEW.NGOLS2)
                    THEN 2
                WHEN -- Derrota -> Vitória
                (:OLD.NGOLS2 > :OLD.NGOLS1 AND :NEW.NGOLS1 > :NEW.NGOLS2)
                    THEN 3
                WHEN -- Empate -> Derrota
                (:OLD.NGOLS1 = :OLD.NGOLS2 AND :NEW.NGOLS2 > :NEW.NGOLS1)
                    THEN -1
                WHEN -- Vitória -> Empate
                (:OLD.NGOLS1 > :OLD.NGOLS2 AND :NEW.NGOLS1 = :NEW.NGOLS2)
                    THEN -2
                WHEN -- Vitória -> Derrota
                (:OLD.NGOLS1 > :OLD.NGOLS2 AND :NEW.NGOLS2 > :NEW.NGOLS1)
                    THEN -3
                ELSE NULL END -- Não deveria chegar neste caso (erro)
            )
        WHERE T.PAIS = :NEW.TIME1;
        
        -- Update TIME2
        UPDATE TIME T SET T.PONTUACAO = (NVL(T.PONTUACAO, 0)
            + CASE WHEN -- Mantém mesmo resultado
                (:OLD.NGOLS1 < :OLD.NGOLS2 AND :NEW.NGOLS1 < :NEW.NGOLS2)
                OR (:OLD.NGOLS1 = :OLD.NGOLS2 AND:NEW.NGOLS1 = :NEW.NGOLS2)
                OR (:OLD.NGOLS2 < :OLD.NGOLS1 AND :NEW.NGOLS2 < :NEW.NGOLS1)
                    THEN 0
                WHEN -- Derrota -> Empate
                (:OLD.NGOLS2 < :OLD.NGOLS1 AND :NEW.NGOLS1 = :NEW.NGOLS2)
                    THEN 1
                WHEN -- Empate -> Vitória
                (:OLD.NGOLS1 = :OLD.NGOLS2 AND :NEW.NGOLS1 < :NEW.NGOLS2)
                    THEN 2
                WHEN -- Derrota -> Vitória
                (:OLD.NGOLS2 < :OLD.NGOLS1 AND :NEW.NGOLS1 < :NEW.NGOLS2)
                    THEN 3
                WHEN -- Empate -> Derrota
                (:OLD.NGOLS1 = :OLD.NGOLS2 AND :NEW.NGOLS2 < :NEW.NGOLS1)
                    THEN -1
                WHEN -- Vitória -> Empate
                (:OLD.NGOLS1 < :OLD.NGOLS2 AND :NEW.NGOLS1 = :NEW.NGOLS2)
                    THEN -2
                WHEN -- Vitória -> Derrota
                (:OLD.NGOLS1 < :OLD.NGOLS2 AND :NEW.NGOLS2 < :NEW.NGOLS1)
                    THEN -3
                ELSE NULL END -- Não deveria chegar neste caso (erro)
            )
        WHERE T.PAIS = :NEW.TIME2;
    
    -- Se removendo, ou atualizando o jogo para outra fase
    ELSIF ((DELETING OR (UPDATING AND (:NEW.FASE <> 'Primeira Fase'
                                        OR :NEW.NGOLS1 IS NULL
                                        OR :NEW.NGOLS2 IS NULL)))
            AND :OLD.FASE = 'Primeira Fase'
            AND :OLD.NGOLS1 IS NOT NULL AND :OLD.NGOLS2 IS NOT NULL) THEN
        -- Update TIME1
        UPDATE TIME T SET T.PONTUACAO = (NVL(T.PONTUACAO, 0)
            - CASE WHEN :OLD.NGOLS1 > :OLD.NGOLS2 THEN 3
                WHEN :OLD.NGOLS1 = :OLD.NGOLS2 THEN 1
                WHEN :OLD.NGOLS2 > :OLD.NGOLS1 THEN 0
                ELSE NULL END -- Não deveria chegar neste caso (erro)
            )
        WHERE T.PAIS = :OLD.TIME1;
        
        -- Update TIME2
        UPDATE TIME T SET T.PONTUACAO = (NVL(T.PONTUACAO, 0)
            - CASE WHEN :OLD.NGOLS1 < :OLD.NGOLS2 THEN 3
                WHEN :OLD.NGOLS1 = :OLD.NGOLS2 THEN 1
                WHEN :OLD.NGOLS2 < :OLD.NGOLS1 THEN 0
                ELSE NULL END -- Não deveria chegar neste caso (erro)
            )
        WHERE T.PAIS = :OLD.TIME2;
    END IF;
END;

/

CREATE OR REPLACE TRIGGER update_time_ntotalgols
/*
    Trigger para inserção ou atualização de jogos.
    Atualiza o número de gols na tabela TIME, para cada jogo inserido, 
        atualizado ou removido.
    Afeta todos os jogos alterados.
    Se algum valor dos gols é nulo, Assume-se que o valor a ser somado é 0.
*/
AFTER INSERT OR UPDATE OR DELETE ON JOGO
FOR EACH ROW
BEGIN
    -- If inserting
    IF INSERTING THEN
        -- Update TIME1
        UPDATE TIME T
            SET T.NTOTALGOLS = (NVL(T.NTOTALGOLS, 0) + NVL(:NEW.NGOLS1, 0))
        WHERE T.PAIS = :NEW.TIME1;
        
        -- Update TIME2
        UPDATE TIME T
            SET T.NTOTALGOLS = (NVL(T.NTOTALGOLS, 0) + NVL(:NEW.NGOLS2, 0))
        WHERE T.PAIS = :NEW.TIME2;
    
    -- If updating
    ELSIF UPDATING THEN
        -- Update TIME1
        UPDATE TIME T
            SET T.NTOTALGOLS = (NVL(T.NTOTALGOLS, 0) + NVL(:NEW.NGOLS1, 0)
                - NVL(:OLD.NGOLS1, 0))
        WHERE T.PAIS = :NEW.TIME1;
        
        -- Update TIME2
        UPDATE TIME T
            SET T.NTOTALGOLS = (NVL(T.NTOTALGOLS, 0) + NVL(:NEW.NGOLS2, 0)
                - NVL(:OLD.NGOLS2, 0))
        WHERE T.PAIS = :NEW.TIME2;
    
    -- If deleting
    ELSIF DELETING THEN
        -- Update TIME1
        UPDATE TIME T
            SET T.NTOTALGOLS = (NVL(T.NTOTALGOLS, 0) - NVL(:OLD.NGOLS1, 0))
        WHERE T.PAIS = :OLD.TIME1;
        
        -- Update TIME2
        UPDATE TIME T
            SET T.NTOTALGOLS = (NVL(T.NTOTALGOLS, 0) - NVL(:OLD.NGOLS2, 0))
        WHERE T.PAIS = :OLD.TIME2;
    END IF;
END;
/
-- Exercício 1b ---------------------------------------------------------------

CREATE OR REPLACE TRIGGER check_jogo_grupo
/*
    Trigger para verificação de consistência da tabela jogo.
    Verifica se, quando o jogo é na fase de grupos, os times envolvidos
        pertencem ao mesmo grupo.
    Se a verificação de consistência falhar, executar raise_application_error,
        para ser tratado em um nível superior.
*/
BEFORE INSERT OR UPDATE ON JOGO
FOR EACH ROW
WHEN (NEW.FASE = 'Primeira Fase')
DECLARE
    v_grupo1 TIME.GRUPO%TYPE;
    v_grupo2 TIME.GRUPO%TYPE;
BEGIN
    SELECT T.GRUPO INTO v_grupo1 FROM TIME T WHERE T.PAIS = :NEW.TIME1;
    SELECT T.GRUPO INTO v_grupo2 FROM TIME T WHERE T.PAIS = :NEW.TIME2;
    IF v_grupo1 <> v_grupo2 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Os times ' || :NEW.TIME1 || ' e '
            || :NEW.TIME2 || ' são de grupos diferentes no jogo '
            || :NEW.NUMERO || ', da primeira fase.');
    END IF;
    -- Neste trigger, não são tratadas exceções.
    -- Estas devem ser tratadas nos níveis superiores.
END;
/
-- Exercício 1c ---------------------------------------------------------------

CREATE OR REPLACE TRIGGER INSERT_TIME_PAIS
/*
    Antes de cada inserção na tabela TIME, na coluna PAIS
        converter valor da coluna PAIS para UPPER.
    Optei por não realizar este trigger após atualizações, devido à questões
        de cascateamento de constraints. Assim, serão tratadas apenas inserções
        de dados futuros.
*/
BEFORE INSERT ON TIME
FOR EACH ROW
WHEN (NEW.PAIS <> UPPER(NEW.PAIS))
BEGIN
    -- Convertendo o novo valor para caixa alta.
    :NEW.PAIS := UPPER(:NEW.PAIS);
END;

/*
    ii. Com a padronização da coluna PAIS da tabela TIME para uppercase, novas
        consultas não precisariam utilizar a função UPPER(PAIS) para garantir a
        igualdade independentemente de caracteres em caixa alta ou caixa baixa.

        Isso permite que o índice de chave primária sobre a coluna TIME seja
        utilizado para tais consultas, melhorando a performance destas.
*/

/

/*
    Testando funcionamento dos triggers criados com um programa PL/SQL
        (utilizando a base de dados inicial)
*/
DECLARE
    v_time1 TIME%ROWTYPE; -- Para testar inserção de novo time
    v_time2 TIME%ROWTYPE; -- Para testar inserção de novo time
    v_jogo JOGO%ROWTYPE; -- Para testar criação, atualização e remoção de jogos
    e_grupo EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_grupo, -20010);
BEGIN
    -- Inserindo novo time (simulando input do usuário)
    v_time1.PAIS := 'Qatar'; v_time1.NFIFA := 555; v_time1.GRUPO := 'H';
    INSERT INTO TIME VALUES (v_time1.PAIS, v_time1.NFIFA, DEFAULT, DEFAULT,
        DEFAULT, DEFAULT, DEFAULT, v_time1.GRUPO, DEFAULT);
    -- Verificando funcionamento do trigger de inserção de times
    SELECT T.* INTO v_time1 FROM TIME T WHERE T.NFIFA = v_time1.NFIFA;
    DBMS_OUTPUT.PUT_LINE('País: ' || v_time1.PAIS || chr(10)
        || 'Ntotalgols: ' || v_time1.NTOTALGOLS || chr(10)
        || 'Grupo: ' || v_time1.GRUPO || chr(10)
        || 'Pontuação: ' || v_time1.PONTUACAO || chr(10));
    /* Resultado:
        País: QATAR
        Ntotalgols: 0
        Grupo: H
        Pontuação: 0
    */

    -- Inserindo novo time (simulando input do usuário)
    v_time2.PAIS := 'Belize'; v_time2.NFIFA := 556; v_time2.GRUPO := 'H';
    INSERT INTO TIME VALUES (v_time2.PAIS, v_time2.NFIFA, DEFAULT, DEFAULT,
        DEFAULT, DEFAULT, DEFAULT, v_time2.GRUPO, DEFAULT);
    -- Verificando funcionamento do trigger de inserção de times
    SELECT T.* INTO v_time2 FROM TIME T WHERE T.NFIFA = v_time2.NFIFA;
    DBMS_OUTPUT.PUT_LINE('País: ' || v_time2.PAIS || chr(10)
        || 'Ntotalgols: ' || v_time2.NTOTALGOLS || chr(10)
        || 'Grupo: ' || v_time2.GRUPO || chr(10)
        || 'Pontuação: ' || v_time2.PONTUACAO || chr(10));
    /* Resultado:
        País: BELIZE
        Ntotalgols: 0
        Grupo: H
        Pontuação: 0
    */

    -- Inserindo novo jogo entre time1 e time2
    v_jogo.NUMERO := 555; v_jogo.FASE := 'Primeira Fase';
    v_jogo.TIME1 := v_time1.PAIS; v_jogo.TIME2 := v_time2.PAIS;
    v_jogo.DATAHORA := SYSDATE; v_jogo.NGOLS1 := 3; v_jogo.NGOLS2 := 2;
    v_jogo.ESTADIO := 'Estadio Moses Mabhida';
    v_jogo.ARBITRO := 'Zé1'; v_jogo.ASSISTENTE1 := 'Zé2';
    v_jogo.ASSISTENTE2 := 'Zé3'; v_jogo.QUARTOARBITRO := 'Zé4';
    INSERT INTO JOGO VALUES (v_jogo.NUMERO, v_jogo.FASE, v_jogo.TIME1,
        v_jogo.TIME2, v_jogo.DATAHORA, v_jogo.NGOLS1, v_jogo.NGOLS2,
        v_jogo.ESTADIO, v_jogo.ARBITRO, v_jogo.ASSISTENTE1, v_jogo.ASSISTENTE2,
        v_jogo.QUARTOARBITRO);
    SELECT J.* INTO v_jogo FROM JOGO J WHERE J.NUMERO = v_jogo.NUMERO;
    DBMS_OUTPUT.PUT_LINE('NUMERO: ' || v_jogo.NUMERO || chr(10)
        || 'FASE: ' || v_jogo.FASE || chr(10)
        || 'TIME1: ' || v_jogo.TIME1 || chr(10)
        || 'TIME2: ' || v_jogo.TIME2 || chr(10)
        || 'NGOLS1: ' || v_jogo.NGOLS1 || chr(10)
        || 'NGOLS2: ' || v_jogo.NGOLS2 || chr(10));
    /* Resultado:
        NUMERO: 555
        FASE: Primeira Fase
        TIME1: QATAR
        TIME2: BELIZE
        NGOLS1: 3
        NGOLS2: 2
    */
    -- Verificando funcionamento dos triggers após inserção do jogo
    SELECT T.* INTO v_time1 FROM TIME T WHERE T.NFIFA = v_time1.NFIFA;
    DBMS_OUTPUT.PUT_LINE('País: ' || v_time1.PAIS || chr(10)
        || 'Ntotalgols: ' || v_time1.NTOTALGOLS || chr(10)
        || 'Grupo: ' || v_time1.GRUPO || chr(10)
        || 'Pontuação: ' || v_time1.PONTUACAO || chr(10));
    SELECT T.* INTO v_time2 FROM TIME T WHERE T.NFIFA = v_time2.NFIFA;
    DBMS_OUTPUT.PUT_LINE('País: ' || v_time2.PAIS || chr(10)
        || 'Ntotalgols: ' || v_time2.NTOTALGOLS || chr(10)
        || 'Grupo: ' || v_time2.GRUPO || chr(10)
        || 'Pontuação: ' || v_time2.PONTUACAO || chr(10));
    /* Resultado:
        País: QATAR
        Ntotalgols: 3
        Grupo: H
        Pontuação: 3

        País: BELIZE
        Ntotalgols: 2
        Grupo: H
        Pontuação: 0

    */

    -- Atualizando jogo inserido, mudando o placar
    UPDATE JOGO SET NGOLS1 = 3, NGOLS2 = 3 WHERE NUMERO = v_jogo.NUMERO;
    SELECT J.* INTO v_jogo FROM JOGO J WHERE J.NUMERO = v_jogo.NUMERO;
    DBMS_OUTPUT.PUT_LINE('NUMERO: ' || v_jogo.NUMERO || chr(10)
        || 'FASE: ' || v_jogo.FASE || chr(10)
        || 'TIME1: ' || v_jogo.TIME1 || chr(10)
        || 'TIME2: ' || v_jogo.TIME2 || chr(10)
        || 'NGOLS1: ' || v_jogo.NGOLS1 || chr(10)
        || 'NGOLS2: ' || v_jogo.NGOLS2 || chr(10));
    /* Resultado:
        NUMERO: 555
        FASE: Primeira Fase
        TIME1: QATAR
        TIME2: BELIZE
        NGOLS1: 3
        NGOLS2: 3
    */
    -- Verificando funcionamento dos triggers após atualização
    SELECT T.* INTO v_time1 FROM TIME T WHERE T.NFIFA = v_time1.NFIFA;
    DBMS_OUTPUT.PUT_LINE('País: ' || v_time1.PAIS || chr(10)
        || 'Ntotalgols: ' || v_time1.NTOTALGOLS || chr(10)
        || 'Grupo: ' || v_time1.GRUPO || chr(10)
        || 'Pontuação: ' || v_time1.PONTUACAO || chr(10));
    SELECT T.* INTO v_time2 FROM TIME T WHERE T.NFIFA = v_time2.NFIFA;
    DBMS_OUTPUT.PUT_LINE('País: ' || v_time2.PAIS || chr(10)
        || 'Ntotalgols: ' || v_time2.NTOTALGOLS || chr(10)
        || 'Grupo: ' || v_time2.GRUPO || chr(10)
        || 'Pontuação: ' || v_time2.PONTUACAO || chr(10));
    /* Resultado:
        País: QATAR
        Ntotalgols: 3
        Grupo: H
        Pontuação: 1

        País: BELIZE
        Ntotalgols: 3
        Grupo: H
        Pontuação: 1
    */

    ROLLBACK; -- Voltando ao estado inicial para testes subsequentes

    -- Testando inserção de jogos com times de grupos diferentes
    v_time1.GRUPO := 'G'; -- Alterando grupo de time1
    v_time2.GRUPO := 'H'; -- Alterando grupo de time2
    INSERT INTO TIME VALUES (v_time1.PAIS, v_time1.NFIFA, DEFAULT, DEFAULT,
        DEFAULT, DEFAULT, DEFAULT, v_time1.GRUPO, DEFAULT);
    INSERT INTO TIME VALUES (v_time2.PAIS, v_time2.NFIFA, DEFAULT, DEFAULT,
        DEFAULT, DEFAULT, DEFAULT, v_time2.GRUPO, DEFAULT);
    SELECT T.* INTO v_time1 FROM TIME T WHERE T.NFIFA = v_time1.NFIFA;
    SELECT T.* INTO v_time2 FROM TIME T WHERE T.NFIFA = v_time2.NFIFA;
    DBMS_OUTPUT.PUT_LINE('País: ' || v_time1.PAIS || chr(10)
        || 'Ntotalgols: ' || v_time1.NTOTALGOLS || chr(10)
        || 'Grupo: ' || v_time1.GRUPO || chr(10)
        || 'Pontuação: ' || v_time1.PONTUACAO || chr(10));
    DBMS_OUTPUT.PUT_LINE('País: ' || v_time2.PAIS || chr(10)
        || 'Ntotalgols: ' || v_time2.NTOTALGOLS || chr(10)
        || 'Grupo: ' || v_time2.GRUPO || chr(10)
        || 'Pontuação: ' || v_time2.PONTUACAO || chr(10));
    /* Resultado:
        País: QATAR
        Ntotalgols: 0
        Grupo: G
        Pontuação: 0

        País: BELIZE
        Ntotalgols: 0
        Grupo: H
        Pontuação: 0
    */
    INSERT INTO JOGO VALUES (v_jogo.NUMERO, v_jogo.FASE, v_jogo.TIME1,
        v_jogo.TIME2, v_jogo.DATAHORA, v_jogo.NGOLS1, v_jogo.NGOLS2,
        v_jogo.ESTADIO, v_jogo.ARBITRO, v_jogo.ASSISTENTE1, v_jogo.ASSISTENTE2,
        v_jogo.QUARTOARBITRO);
    /* Resultado (erro):
        ORA-20010: Os times QATAR e BELIZE são de grupos diferentes no jogo 555, da primeira fase.
        ORA-06512: em "A9778985.CHECK_JOGO_GRUPO", line 8
        ORA-04088: erro durante a execução do gatilho 'A9778985.CHECK_JOGO_GRUPO'
    */
    
    ROLLBACK;
    EXCEPTION
        WHEN no_data_found THEN
            DBMS_OUTPUT.PUT_LINE('Tentativa de acesso a elemento sem atribuição');
            ROLLBACK;
        WHEN e_grupo THEN -- Erro na inserção na tabela JOGO
            DBMS_OUTPUT.PUT_LINE(SQLERRM);
            ROLLBACK;
        WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('ERRO NRO: ' || SQLCODE || '; MENSAGEM: ' || SQLERRM);
            ROLLBACK;

END;

/*
    Neste programa PL/SQL, foi possível verificar o funcionamento dos triggers
        criados.
    Quando há a inserção inválida na tabela JOGO, o trigger levanta a exceção,
    cuja mensagem é impressa para o usuário.

    Os resultados de cada etapa estão nos comentários dentro do próprio programa.
*/
/
-- Exercício 2a ---------------------------------------------------------------

CREATE OR REPLACE VIEW VIEW_JOGO
    (JOGO, FASE, DATAHORA, TIME1, NFIFA1, GRUPO1, TIME2, NFIFA2, GRUPO2,
    ESTADIO, CIDADE) AS
    SELECT J.NUMERO, J.FASE, J.DATAHORA, J.TIME1, T1.NFIFA NFIFA1,
            T1.GRUPO GRUPO1, J.TIME2, T2.NFIFA NFIFA2, T2.GRUPO GRUPO2,
            E.NOME ESTADIO, E.CIDADE CIDADE FROM JOGO J
        INNER JOIN TIME T1 ON J.TIME1 = T1.PAIS
        INNER JOIN TIME T2 ON J.TIME2 = T2.PAIS
        INNER JOIN ESTADIO E ON J.ESTADIO = E.NOME;

/*
    i.  Nesta visão, apenas a tabela JOGO tem preservação de chave, isto é,
        uma tupla da tabela JOGO há no máximo uma tupla correspondente na visão.
        
        Sendo assim, apenas as colunas provenientes da tabela JOGO são
        atualizáveis. Quaisquer operações DML afetarão somente tuplas que
        correspondem à esta tabela.
    ii.
        Operações de UPDATE só podem afetar colunas da tabela JOGO.
        Operações de INSERT só irão inserir tuplas na tabela JOGO.
        Operações de DELETE só irão remover tuplas da tabela JOGO.
        
        Obs.: O SGBD ainda pode utilizar predicados da visão para filtrar as
        tuplas em questão, mas as operações de DML serão efetuadas somente
        sobre a tabela JOGO.
*/

/* Resultado de um SELECT sobre a view:
    JOGO    FASE    DATAHORA    TIME1   NFIFA1  GRUPO1  TIME2   NFIFA2  GRUPO2  ESTADIO CIDADE
    34	Primeira Fase	22/06/22	Franca	5	A	Africa do Sul	2	A	Estadio Free State	Mangaung/Bloemfontein
    21	Primeira Fase	17/06/22	Franca	5	A	Mexico	3	A	Estadio Peter Mokaba	Polokwane
    2	Primeira Fase	11/06/22	Africa do Sul	2	A	Mexico	3	A	Estadio Soccer City	Joanesburgo
    35	Primeira Fase	22/06/22	Mexico	3	A	Uruguai	4	A	Estadio Royal Bafokeng	Rustemburgo
    18	Primeira Fase	16/06/22	Africa do Sul	2	A	Uruguai	4	A	Estadio Loftus Versfeld	Tshwane/Pretoria
    3	Primeira Fase	11/06/22	Uruguai	4	A	Franca	5	A	Estadio Green Point	Cidade do Cabo
    36	Primeira Fase	22/06/22	Grecia	9	B	Argentina	6	A	Estadio Peter Mokaba	Polokwane
    20	Primeira Fase	17/06/22	Grecia	9	B	Nigeria	7	B	Estadio Free State	Mangaung/Bloemfontein
    5	Primeira Fase	12/06/22	Argentina	6	A	Nigeria	7	B	Estadio Ellis Park	Joanesburgo
    37	Primeira Fase	22/06/22	Nigeria	7	B	Coreia do Sul	8	B	Estadio Moses Mabhida	Durban
    19	Primeira Fase	17/06/22	Argentina	6	A	Coreia do Sul	8	B	Estadio Soccer City	Joanesburgo
    4	Primeira Fase	12/06/22	Coreia do Sul	8	B	Grecia	9	B	Estadio Nelson Mandela Bay	Nelson Mandela Bay/Port Elizabeth
    38	Primeira Fase	23/06/22	Eslovenia	13	C	Inglaterra	10	C	Estadio Nelson Mandela Bay	Nelson Mandela Bay/Port Elizabeth
    23	Primeira Fase	18/06/22	Eslovenia	13	C	Estados Unidos	11	C	Estadio Ellis Park	Joanesburgo
    6	Primeira Fase	12/06/22	Inglaterra	10	C	Estados Unidos	11	C	Estadio Royal Bafokeng	Rustemburgo
    39	Primeira Fase	23/06/22	Estados Unidos	11	C	Argelia	12	C	Estadio Loftus Versfeld	Tshwane/Pretoria
    24	Primeira Fase	18/06/22	Inglaterra	10	C	Argelia	12	C	Estadio Green Point	Cidade do Cabo
    7	Primeira Fase	13/06/22	Argelia	12	C	Eslovenia	13	C	Estadio Peter Mokaba	Polokwane
    41	Primeira Fase	23/06/22	Gana	17	D	Alemanha	14	D	Estadio Soccer City	Joanesburgo
    26	Primeira Fase	19/06/22	Gana	17	D	Australia	15	D	Estadio Royal Bafokeng	Rustemburgo
    9	Primeira Fase	13/06/22	Alemanha	14	D	Australia	15	D	Estadio Moses Mabhida	Durban
    40	Primeira Fase	23/06/22	Australia	15	D	Servia	16	D	Estadio Mbombela	Nelspruit
    22	Primeira Fase	18/06/22	Alemanha	14	D	Servia	16	D	Estadio Nelson Mandela Bay	Nelson Mandela Bay/Port Elizabeth
    8	Primeira Fase	13/06/22	Servia	16	D	Gana	17	D	Estadio Loftus Versfeld	Tshwane/Pretoria
    45	Primeira Fase	24/06/22	Camaroes	21	E	Holanda	18	E	Estadio Green Point	Cidade do Cabo
    27	Primeira Fase	19/06/22	Camaroes	21	E	Dinamarca	19	E	Estadio Loftus Versfeld	Tshwane/Pretoria
    10	Primeira Fase	14/06/22	Holanda	18	E	Dinamarca	19	E	Estadio Soccer City	Joanesburgo
    44	Primeira Fase	24/06/22	Dinamarca	19	E	Japao	20	E	Estadio Royal Bafokeng	Rustemburgo
    25	Primeira Fase	19/06/22	Holanda	18	E	Japao	20	E	Estadio Moses Mabhida	Durban
    11	Primeira Fase	14/06/22	Japao	20	E	Camaroes	21	E	Estadio Free State	Mangaung/Bloemfontein
    43	Primeira Fase	24/06/22	Eslovaquia	25	F	Italia	22	F	Estadio Ellis Park	Joanesburgo
    28	Primeira Fase	20/06/22	Eslovaquia	25	F	Paraguai	23	F	Estadio Free State	Mangaung/Bloemfontein
    12	Primeira Fase	14/06/22	Italia	22	F	Paraguai	23	F	Estadio Green Point	Cidade do Cabo
    42	Primeira Fase	24/06/22	Paraguai	23	F	Nova Zelandia	24	F	Estadio Peter Mokaba	Polokwane
    29	Primeira Fase	20/06/22	Italia	22	F	Nova Zelandia	24	F	Estadio Mbombela	Nelspruit
    13	Primeira Fase	15/06/22	Nova Zelandia	24	F	Eslovaquia	25	F	Estadio Royal Bafokeng	Rustemburgo
    46	Primeira Fase	25/06/22	Portugal	29	G	Brasil	26	G	Estadio Moses Mabhida	Durban
    31	Primeira Fase	21/06/22	Portugal	29	G	Coreia do Norte	27	G	Estadio Green Point	Cidade do Cabo
    15	Primeira Fase	15/06/22	Brasil	26	G	Coreia do Norte	27	G	Estadio Ellis Park	Joanesburgo
    47	Primeira Fase	25/06/22	Coreia do Norte	27	G	Costa do Marfim	28	G	Estadio Mbombela	Nelspruit
    30	Primeira Fase	20/06/22	Brasil	26	G	Costa do Marfim	28	G	Estadio Soccer City	Joanesburgo
    14	Primeira Fase	15/06/22	Costa do Marfim	28	G	Portugal	29	G	Estadio Nelson Mandela Bay	Nelson Mandela Bay/Port Elizabeth
    48	Primeira Fase	25/06/22	Chile	33	H	Espanha	30	H	Estadio Loftus Versfeld	Tshwane/Pretoria
    32	Primeira Fase	21/06/22	Chile	33	H	Suica	31	H	Estadio Nelson Mandela Bay	Nelson Mandela Bay/Port Elizabeth
    17	Primeira Fase	16/06/22	Espanha	30	H	Suica	31	H	Estadio Moses Mabhida	Durban
    49	Primeira Fase	25/06/22	Suica	31	H	Honduras	32	H	Estadio Free State	Mangaung/Bloemfontein
    33	Primeira Fase	21/06/22	Espanha	30	H	Honduras	32	H	Estadio Ellis Park	Joanesburgo
    16	Primeira Fase	16/06/22	Honduras	32	H	Chile	33	H	Estadio Mbombela	Nelspruit
*/

/
-- Exercício 2b ---------------------------------------------------------------

CREATE OR REPLACE TRIGGER dml_view_jogo
/*
    Esta trigger altera o comportamento de operações de DML sobre a visão
    VIEW_JOGO.
    Os novos comportamentos estão como a seguir:
        INSERT: Executa um raise_application_error, efetivamente restringindo
        toda operação de inserção utilizando a visão VIEW_JOGO.
        UPDATE: Para cada tupla que seria afetada pelo update, atualizar apenas
        a coluna JOGO.DATAHORA para o tempo atual do sistema (SYSDATE).
        DELETE: Para cada tupla que seria afetada pela remoção, atualizar
        na tabela JOGO os campos NGOLS1 := NULL, NGOLS2 := NULL.
        
    Obs.: Não consegui pensar em operações que teriam algum significado
        semântico sobre a base de dados. Por isso, optei por utilizar estas
        operações neste trigger.
    
*/
INSTEAD OF INSERT OR UPDATE OR DELETE ON VIEW_JOGO
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        RAISE_APPLICATION_ERROR(-20011,
            'Não é permitida a inserção através da VIEW_JOGO');
    ELSIF UPDATING THEN
        UPDATE JOGO SET DATAHORA = SYSDATE
            WHERE NUMERO = :OLD.JOGO;
    ELSIF DELETING THEN
        UPDATE JOGO SET NGOLS1 = NULL, NGOLS2 = NULL
            WHERE NUMERO = :OLD.JOGO;
    END IF;
END;

/

/* 
    Testando funcionamento do trigger;
*/

DECLARE
    TYPE T_JOGOS IS TABLE OF JOGO%ROWTYPE INDEX BY PLS_INTEGER;
    v_jogos_pre T_JOGOS;
    v_jogos T_JOGOS;
    v_jogo JOGO%ROWTYPE;
    e_insert EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_insert, -20011);
BEGIN
    -- Verificando tuplas, antes do UPDATE
    SELECT J.* BULK COLLECT INTO v_jogos_pre FROM JOGO J
        WHERE UPPER(J.TIME1) = 'BRASIL' OR UPPER(J.TIME2) = 'BRASIL';
    
    FOR i IN v_jogos_pre.FIRST .. v_jogos_pre.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('NUMERO: ' || v_jogos_pre(i).NUMERO || chr(10)
            || 'FASE: ' || v_jogos_pre(i).FASE || chr(10)
            || 'DATAHORA: ' || v_jogos_pre(i).DATAHORA|| chr(10)
            || 'TIME1: ' || v_jogos_pre(i).TIME1 || chr(10)
            || 'TIME2: ' || v_jogos_pre(i).TIME2 || chr(10)
            || 'NGOLS1: ' || v_jogos_pre(i).NGOLS1 || chr(10)
            || 'NGOLS2: ' || v_jogos_pre(i).NGOLS2 || chr(10));
    END LOOP;
    /* Resultado:
        NUMERO: 15
        FASE: Primeira Fase
        DATAHORA: 15/06/22
        TIME1: Brasil
        TIME2: Coreia do Norte
        NGOLS1: 4
        NGOLS2: 1
        
        NUMERO: 30
        FASE: Primeira Fase
        DATAHORA: 20/06/22
        TIME1: Brasil
        TIME2: Costa do Marfim
        NGOLS1: 3
        NGOLS2: 1
        
        NUMERO: 46
        FASE: Primeira Fase
        DATAHORA: 25/06/22
        TIME1: Portugal
        TIME2: Brasil
        NGOLS1: 0
        NGOLS2: 1    
    */
    
    -- Testando UPDATE
    UPDATE VIEW_JOGO SET FASE = 'FINAL' 
        WHERE UPPER(TIME1) = 'BRASIL' OR UPPER(TIME2) = 'BRASIL';
    SELECT J.* BULK COLLECT INTO v_jogos FROM JOGO J
        WHERE UPPER(J.TIME1) = 'BRASIL' OR UPPER(J.TIME2) = 'BRASIL';
    
    FOR i IN v_jogos.FIRST .. v_jogos.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('NUMERO: ' || v_jogos(i).NUMERO || chr(10)
            || 'FASE: ' || v_jogos(i).FASE || chr(10)
            || 'DATAHORA: ' || v_jogos(i).DATAHORA|| chr(10)
            || 'TIME1: ' || v_jogos(i).TIME1 || chr(10)
            || 'TIME2: ' || v_jogos(i).TIME2 || chr(10)
            || 'NGOLS1: ' || v_jogos(i).NGOLS1 || chr(10)
            || 'NGOLS2: ' || v_jogos(i).NGOLS2 || chr(10));
    END LOOP;
    /* Resultado, após o UPDATE:
        NUMERO: 15
        FASE: Primeira Fase
        DATAHORA: 17/06/19
        TIME1: Brasil
        TIME2: Coreia do Norte
        NGOLS1: 4
        NGOLS2: 1
        
        NUMERO: 30
        FASE: Primeira Fase
        DATAHORA: 17/06/19
        TIME1: Brasil
        TIME2: Costa do Marfim
        NGOLS1: 3
        NGOLS2: 1
        
        NUMERO: 46
        FASE: Primeira Fase
        DATAHORA: 17/06/19
        TIME1: Portugal
        TIME2: Brasil
        NGOLS1: 0
        NGOLS2: 1

        É possível notar que a DATAHORA foi alterada.
    */

    ROLLBACK; -- Voltando ao estado inicial

    -- Testando DELETE
    DELETE FROM VIEW_JOGO WHERE JOGO = 15; -- Primeira tupla dos resultados anteriores
    SELECT J.* INTO v_jogo FROM JOGO J WHERE J.NUMERO = 15;
    DBMS_OUTPUT.PUT_LINE('NUMERO: ' || v_jogo.NUMERO || chr(10)
            || 'FASE: ' || v_jogo.FASE || chr(10)
            || 'TIME1: ' || v_jogo.TIME1 || chr(10)
            || 'TIME2: ' || v_jogo.TIME2 || chr(10)
            || 'NGOLS1: ' || v_jogo.NGOLS1 || chr(10)
            || 'NGOLS2: ' || v_jogo.NGOLS2 || chr(10));
    /* Resultado:
        NUMERO: 15
        FASE: Primeira Fase
        TIME1: Brasil
        TIME2: Coreia do Norte
        NGOLS1: 
        NGOLS2: 
        
        É possível notar que as colunas NGOLS1 e NGOLS2 foram alteradas para NULL.
    */
    ROLLBACK; -- Voltando ao estado inicial

    -- Testando INSERT
    INSERT INTO VIEW_JOGO (JOGO, FASE, DATAHORA, TIME1, TIME2, ESTADIO) VALUES 
        (500, 'Primeira Fase', SYSDATE, 'Brasil', 'Franca', 'Estadio Free State');
    /* Resultado (erro):
        Inserção na VIEW_JOGO não permitida.
    */
    
    ROLLBACK;
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
		WHEN e_insert THEN
            DBMS_OUTPUT.PUT_LINE('Inserção na VIEW_JOGO não permitida.');
            ROLLBACK;
		WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERRO NRO: ' || SQLCODE || '; MENSAGEM: ' || SQLERRM);
            ROLLBACK;
END;

/

DROP TRIGGER dml_view_jogo;
/*
    No programa PL/SQL, foram vistas as alterações no comportamento do SGBD,
    causadas pelo trigger.

    Enquanto, neste caso, os novos comportamentos têm pouco significado semântico,
    foi possível ter o entendimento de como alterar o comportamento do SGBD para
    casos similares.
*/
/
-- Exercício 3a ---------------------------------------------------------------

/*
    Criando tabela para armazenar o LOG
    (dropando a tabela se já existe, e recriando)
*/
BEGIN
    -- Dropando tabela
    BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE DDLLOG CASCADE CONSTRAINTS';
      EXCEPTION WHEN OTHERS THEN NULL; -- Se não existe, tratar exceção
    END;
    -- Criando tabela
    EXECUTE IMMEDIATE
    'CREATE TABLE DDLLOG (
        USUARIO VARCHAR2(255),
        DATAHORA DATE,
        OPERACAO VARCHAR2(255),
        TIPO_OBJETO VARCHAR2(255),
        NOME_OBJETO VARCHAR2(255)
    )';
END;

/
-- Exercício 3b ---------------------------------------------------------------

/*
    Criando trigger para inserção na tabela de LOG
*/
CREATE OR REPLACE TRIGGER LOGDDL
AFTER DDL ON SCHEMA
BEGIN
    INSERT INTO DDLLOG VALUES (USER, SYSDATE, ORA_SYSEVENT, ORA_DICT_OBJ_TYPE, ORA_DICT_OBJ_NAME);
    -- Exceções devem ser tratadas em níveis superiores
END;

-- Exercício 3c ---------------------------------------------------------------

/*
    Testando o trigger com uma operação DDL
*/

CREATE TABLE TESTING (
    TESTSTRING VARCHAR2(255) PRIMARY KEY
);
/

SELECT * FROM DDLLOG;
/* Resultado (na tabela de LOG;
    A9778985	17/06/19	CREATE	INDEX	SYS_C001150424
    A9778985	17/06/19	CREATE	TABLE	TESTING
    
    Percebe-se que houveram duas operações: Uma para a criação da tabela,
    e uma para a criação do índice de chave primária.
*/

-- Exercício 3d ---------------------------------------------------------------
/*
    Tentando remover a tabela de LOG
*/
DROP TABLE DDLLOG;

/*
    Ocorreu o seguinte erro:
    Relatório de erros -
    ORA-04045: erros durante a recompilação/revalidação de A9778985.LOGDDL
    ORA-00600: código de erro interno, argumentos: [16221], [1794], [DDLLOG], [], [], [], [], [], [], [], [], []
    04045. 00000 -  "errors during recompilation/revalidation of %s.%s"
    *Cause:    This message indicates the object to which the following
               errors apply.  The errors occurred during implicit
               recompilation/revalidation of the object.
    *Action:   Check the following errors for more information, and
               make the necessary corrections to the object.
               
    A tabela DDLLOG não foi removida.
*/    
DROP TABLE TESTING;
/*
    O trigger ainda foi executado com sucesso, com o seguinte resultado
        para a tabela DDLLOG:
        A9778985	17/06/19	CREATE	INDEX	SYS_C001150424
        A9778985	17/06/19	CREATE	TABLE	TESTING
        A9778985	17/06/19	DROP	TABLE	TESTING

    No status do trigger, aparece a seguinte mensagem:
        Required tables DBMSHP_FUNCTION_INFO,DBMSHP_PARENT_CHILD_INFO,DBMSHP_RUNS missing
    
    Aparentemente, devido à dependência cíclica do trigger com a tabela,
        não é possível remover a tabela sem antes remover opróprio trigger.
*/

-- Exercício 4a ---------------------------------------------------------------
/*
    O problema da tabela mutante ocorre quando há a tentativa de referenciar a
    tabela em uma consulta dentro de um trigger que executa linha-a-linha,
    sobre a mesma tabela. Quando esse cenário acontece, o Oracle levanta a
    exceção ORA-04091.

    Isto acontece pois durante a modificação na tabela, resultados de 
    consultas dentro do trigger linha-a-linha podem ser modificados, gerando
    inconsistências. O SGBD detecta isso, e impede que o trigger seja executado.
*/
