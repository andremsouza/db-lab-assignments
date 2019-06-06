/*
	Nome: André Moreira Souza    N°USP: 9778985
	Prática 11 - Triggers
*/

-- Exercício 1a ----------------------------------------------------------------

CREATE OR REPLACE TRIGGER update_time_pontuacao
    /*
        Trigger para inserção ou atualização de jogos.
        Atualiza a pontuação na tabela TIME, para cada jogo inserido, 
            atualizado ou removido.
    */
	AFTER INSERT OR UPDATE OR DELETE ON JOGO
    FOR EACH ROW
	-- Executar apenas quando todos os valores envolvidos não são nulos,
	-- 	apenas para jogos da primeira fase.
	WHEN ((INSERTING AND NEW.FASE = 'Primeira Fase'
			AND NEW.NGOLS1 IS NOT NULL AND NEW.NGOLS2 IS NOT NULL)
		OR (UPDATING AND NEW.FASE = 'Primeira Fase'
			AND OLD.FASE = 'Primeira Fase' AND NEW.NGOLS1 IS NOT NULL
			AND NEW.NGOLS2 IS NOT NULL)
		OR (DELETING AND OLD.NGOLS1 IS NOT NULL AND OLD.NGOLS2 IS NOT NULL))
	BEGIN
        -- If inserting
        IF INSERTING 
		OR (UPDATING AND (:OLD.NGOLS1 IS NULL OR :OLD.NGOLS2 IS NULL)) THEN
            -- Update TIME1
            UPDATE TIME T
                SET T.PONTUACAO = (T.PONTUACAO
                + CASE WHEN :NEW.NGOLS1 > :NEW.NGOLS2 THEN 3
                    WHEN :NEW.NGOLS1 = :NEW.NGOLS2 THEN 1
                    WHEN :NEW.NGOLS2 > :NEW.NGOLS1 THEN 0
                    ELSE NULL END
                )
            WHERE T.PAIS = :NEW.TIME1;
            
            -- Update TIME2
            UPDATE TIME T SET T.PONTUACAO = (T.PONTUACAO
                + CASE WHEN :NEW.NGOLS1 < :NEW.NGOLS2 THEN 3
                    WHEN :NEW.NGOLS1 = :NEW.NGOLS2 THEN 1
                    WHEN :NEW.NGOLS2 < :NEW.NGOLS1 THEN 0
                    ELSE NULL END
                )
            WHERE T.PAIS = :NEW.TIME2;
        
        -- If updating
        ELSIF UPDATING THEN
            -- Update TIME1
            UPDATE TIME T SET T.PONTUACAO = (T.PONTUACAO
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
                    ELSE NULL END
                )
            WHERE T.PAIS = :NEW.TIME1;
            
            -- Update TIME2
			UPDATE TIME T SET T.PONTUACAO = (T.PONTUACAO
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
                    ELSE NULL END
                )
            WHERE T.PAIS = :NEW.TIME2;
        
        -- If deleting
        ELSIF DELETING THEN
            -- Update TIME1
            UPDATE TIME T SET T.PONTUACAO = (T.PONTUACAO
                - CASE WHEN :OLD.NGOLS1 > :OLD.NGOLS2 THEN 3
                    WHEN :OLD.NGOLS1 = :OLD.NGOLS2 THEN 1
                    WHEN :OLD.NGOLS2 > :OLD.NGOLS1 THEN 0
                    ELSE NULL END
                )
            WHERE T.PAIS = :OLD.TIME1;
            
            -- Update TIME2
            UPDATE TIME T SET T.PONTUACAO = (T.PONTUACAO
                - CASE WHEN :OLD.NGOLS1 < :OLD.NGOLS2 THEN 3
                    WHEN :OLD.NGOLS1 = :OLD.NGOLS2 THEN 1
                    WHEN :OLD.NGOLS2 < :OLD.NGOLS1 THEN 0
                    ELSE NULL END
                )
            WHERE T.PAIS = :OLD.TIME2;
        END IF;
	END;

CREATE OR REPLACE TRIGGER update_time_ntotalgols
    /*
        Trigger para inserção ou atualização de jogos.
        Atualiza o número de gols na tabela TIME, para cada jogo inserido, atualizado ou removido.
    */
	AFTER INSERT OR UPDATE OR DELETE ON JOGO
    FOR EACH ROW
	WHEN ((INSERTING AND NEW.NGOLS1 IS NOT NULL AND NEW.NGOLS2 IS NOT NULL)
		OR (UPDATING AND OLD.NGOLS1 IS NOT NULL	AND OLD.NGOLS2 IS NOT NULL
			AND NEW.NGOLS1 IS NOT NULL AND NEW.NGOLS2 IS NOT NULL)
		OR (DELETING AND OLD.NGOLS1 IS NOT NULL AND OLD.NGOLS2 IS NOT NULL))
    BEGIN
        -- If inserting
        IF INSERTING THEN
            -- Update TIME1
            UPDATE TIME T
                SET T.NTOTALGOLS = (T.NTOTALGOLS + :NEW.NGOLS1)
            WHERE T.PAIS = :NEW.TIME1;
            
            -- Update TIME2
            UPDATE TIME T
                SET T.NTOTALGOLS = (T.NTOTALGOLS + :NEW.NGOLS2)
            WHERE T.PAIS = :NEW.TIME2;
        
        -- If updating
        ELSIF UPDATING THEN
            -- Update TIME1
            UPDATE TIME T
                SET T.NTOTALGOLS = (T.NTOTALGOLS + :NEW.NGOLS1 - :OLD.NGOLS1)
            WHERE T.PAIS = :NEW.TIME1;
            
            -- Update TIME2
			UPDATE TIME T
                SET T.NTOTALGOLS = (T.NTOTALGOLS + :NEW.NGOLS2 - :OLD.NGOLS2)
            WHERE T.PAIS = :NEW.TIME2;
        
        -- If deleting
        ELSIF DELETING THEN
            -- Update TIME1
            UPDATE TIME T
                SET T.NTOTALGOLS = (T.NTOTALGOLS - :OLD.NGOLS1)
            WHERE T.PAIS = :OLD.TIME1;
            
            -- Update TIME2
            UPDATE TIME T
                SET T.NTOTALGOLS = (T.NTOTALGOLS - :OLD.NGOLS2)
            WHERE T.PAIS = :OLD.TIME2;
        END IF;
    END;

-- Exercício 1b ---------------------------------------------------------------