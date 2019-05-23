/*
	Nome: André Moreira Souza    N°USP: 9778985
	Prática 8 - PL/SQL - Coleções
*/

-- Exercício 1 --------------------------------------------------------------------------------------------------------

/*
	a) São necessários os privilégios CREATE PROCEDURE, ALTER PROCEDURE, DROP PROCEDURE, ou EXECUTE PROCEDURE, para objetos do próprio esquema do usuário. Esses privilégios são todos de sistema.

	b) Para isto, é necessário o privilégio de objeto EXECUTE PROCEDURE, sobre o procedimento em questão. Além disso, pode ser definido que o usuário que executa a procedure em questão precise dos privilégios utilizados durante a execução desta (e.g. alteração de uma tabela durante a procedure).
*/

-- Exercício 2 --------------------------------------------------------------------------------------------------------

/*
	Criando procedimento
*/

CREATE OR REPLACE PROCEDURE insert_jogo (
	p_numero IN jogo.numero%TYPE,
	p_fase IN jogo.fase%TYPE,
	p_time1 IN jogo.time1%TYPE,
	p_time2 IN jogo.time2%TYPE,
	p_datahora IN jogo.datahora%TYPE,
	p_ngols1 IN jogo.ngols1%TYPE,
	p_ngols2 IN jogo.ngols2%TYPE,
	p_estadio IN jogo.estadio%TYPE,
	p_arbitro IN jogo.arbitro%TYPE,
	p_assistente1 IN jogo.assistente1%TYPE,
	p_assistente2 IN jogo.assistente2%TYPE,
	p_quartoarbitro IN jogo.quartoarbitro%TYPE
) AS
-- Inicializando exceções para tratamento de erros Oracle
e_unique_viol EXCEPTION;
e_notnull_viol EXCEPTION;
e_check_viol EXCEPTION;
e_fk_viol EXCEPTION;
e_numeric_size EXCEPTION;
e_string_too_long EXCEPTION;
e_no_table EXCEPTION;
PRAGMA EXCEPTION_INIT(e_unique_viol, -00001);
PRAGMA EXCEPTION_INIT(e_notnull_viol, -01400);
PRAGMA EXCEPTION_INIT(e_check_viol, -02290);
PRAGMA EXCEPTION_INIT(e_fk_viol, -02291);
PRAGMA EXCEPTION_INIT(e_numeric_size, -01438);
PRAGMA EXCEPTION_INIT(e_string_too_long, -12899);
PRAGMA EXCEPTION_INIT(e_no_table, -00942);
BEGIN
	-- Realizando inserção
	INSERT INTO JOGO VALUES (p_numero, p_fase, p_time1, p_time2, p_datahora, p_ngols1, p_ngols2, p_estadio, p_arbitro, 
		p_assistente1, p_assistente2, p_quartoarbitro);
	
	-- Tratando possíveis exceções
	EXCEPTION
		WHEN e_unique_viol THEN raise_application_error(-20001, 'Este jogo já existe.');
		WHEN e_notnull_viol THEN raise_application_error(-20002, 'Houve uma violação de uma constraint NOT-NULL. DETALHES: ' || SQLERRM);
		WHEN e_check_viol THEN raise_application_error(-20003, 'Houve uma violação de uma constraint CHECK. DETALHES: ' || SQLERRM);
		WHEN e_fk_viol THEN raise_application_error(-20004, 'Houve uma violação de uma constraint FOREIGN-KEY. DETALHES: ' || SQLERRM);
		WHEN e_numeric_size THEN raise_application_error(-20005, 'Um parâmetro numérico é muito grande para a precisão de um atributo da tabela. DETALHES: ' || SQLERRM);
		WHEN e_string_too_long THEN raise_application_error(-20006, 'Uma string entre os parâmetros é muito longa para a tabela. DETALHES: ' || SQLERRM);
		WHEN e_no_table THEN raise_application_error(-20007, 'Esta tabela não existe.');
		WHEN OTHERS THEN raise_application_error(-20999, 'ERRO NRO: ' || SQLCODE || '; MENSAGEM: ' || SQLERRM);
END;

/*
	Testando funcionamento da procedure.
*/

EXECUTE insert_jogo(66768, 'Primeira Fase', 'Brasil', 'Holanda', TO_DATE('27/06/2022', 'dd/mm/yyyy'), 0, 0, 'Estadio Soccer City', 'A', 'B', 'C', 'D');

/*
	Output (quando executado com sucesso):
	PL/SQL procedure successfully completed.

	Obs.: Quando há uma exceção quanto à inserção na tabela JOGO, uma mensagem apropriada é levantada pela procedure.
*/

-- Exercício 3 --------------------------------------------------------------------------------------------------------

/*
	Criando função
*/

CREATE OR REPLACE FUNCTION get_hospedagem RETURN SYS_REFCURSOR
IS
-- sys_refcursor de retorno
ret_cursor SYS_REFCURSOR;
BEGIN
	-- abrindo cursor
	OPEN ret_cursor FOR
		SELECT T.PAIS, T.NFIFA, H.HOTEL, H.NDELEGACAO, PH.DTAENTRADA, PH.DTASAIDA FROM TIME T
			LEFT JOIN HOSPEDA H ON T.PAIS = H.TIME
			LEFT JOIN PERIODOHOSP PH ON H.TIME = PH.TIME AND H.HOTEL = PH.HOTEL;
	RETURN ret_cursor;
	-- Existem poucas exceções (semânticas) relacionadas a esta função. Caberá à aplicação (a seguir) tratar quaisquer outros erros.
	EXCEPTION
	WHEN OTHERS THEN RAISE;
END;

/*
	Testando funcionamento da função, através de um programa em PL/SQL.
*/

DECLARE
	-- Tipo: registro para guardar dados da função em uma collection.
	TYPE T_HOSPEDA IS RECORD (
		PAIS TIME.PAIS%TYPE,
		NFIFA TIME.NFIFA%TYPE,
		HOTEL HOSPEDA.HOTEL%TYPE,
		NDELEGACAO HOSPEDA.NDELEGACAO%TYPE,
		DTAENTRADA PERIODOHOSP.DTAENTRADA%TYPE,
		DTASAIDA PERIODOHOSP.DTASAIDA%TYPE
	);
	-- Tipo: coleção para guardar dados da função
	TYPE T_HOSPEDAGENS IS TABLE OF T_HOSPEDA INDEX BY PLS_INTEGER;
	v_hospedagens T_HOSPEDAGENS;
	c1 SYS_REFCURSOR; -- recuperar retorno de get_hospedagem()
	-- definindo exceções semânticas
	e_noteams EXCEPTION;
BEGIN
	-- Executando função e armazenando em uma coleção
	c1 := get_hospedagem();
	FETCH c1 BULK COLLECT INTO v_hospedagens;
	CLOSE c1;
	
	-- Verificando erro semântico (sem times)
	IF v_hospedagens.COUNT = 0 THEN
		RAISE e_noteams;
	END IF;

	-- Imprimindo resultados
	DBMS_OUTPUT.PUT_LINE('PAIS' || chr(9) || 'NFIFA' || chr(9) || 'HOTEL' || chr(9) || 'NDELEGACAO' || chr(9) || 'DTAENTRADA' ||
		chr(9) || 'DTASAIDA');
	FOR i in v_hospedagens.FIRST .. v_hospedagens.LAST LOOP
		DBMS_OUTPUT.PUT_LINE(v_hospedagens(i).pais || chr(9) || v_hospedagens(i).nfifa || chr(9) || v_hospedagens(i).hotel ||
		chr(9) || v_hospedagens(i).ndelegacao || chr(9) || v_hospedagens(i).dtaentrada || chr(9) || v_hospedagens(i).dtasaida);
	END LOOP;

	-- Tratando exceções
	EXCEPTION
		WHEN SUBSCRIPT_BEYOND_COUNT THEN DBMS_OUTPUT.PUT_LINE('Acesso indevido à uma coleção (elemento fora dos limites).'); ROLLBACK;
		WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Tentativa de acesso a elemento sem atribuição'); ROLLBACK;
		WHEN VALUE_ERROR THEN DBMS_OUTPUT.PUT_LINE('Tentativa de acesso a um elemento fora do intervalo do tipo de dados PLS_INTEGER.'); ROLLBACK;
		WHEN e_noteams THEN DBMS_OUTPUT.PUT_LINE('Não existem times na base de dados.'); ROLLBACK;
		WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('ERRO NRO: ' || SQLCODE || '; MENSAGEM: ' || SQLERRM); ROLLBACK;
END;

/*
	Erros comuns foram tratados no segmento de exceções do programa.

	Resultado esperado, para a base padrão:
	
	PAIS	NFIFA	HOTEL	NDELEGACAO	DTAENTRADA	DTASAIDA
	Africa do Sul	2	Southern Sun Grayton	60	08-JUN-22	
	Mexico	3	Thaba ya Bastswana Eco Lodge	55	08-JUN-22	12-JUN-22
	Uruguai	4	Protea Hotel	50	08-JUN-22	
	Franca	5	Pezula Resort Hotel	58	08-JUN-22	12-JUN-22
	Argentina	6	High Performance Centre	48	09-JUN-22	13-JUN-22
	Nigeria	7	Hampshire Hotel	40	09-JUN-22	13-JUN-22
	Coreia do Sul	8	Hunters Rest Hotel	43	09-JUN-22	13-JUN-22
	Grecia	9	Berverley Hills Hotel	50	09-JUN-22	13-JUN-22
	Inglaterra	10	Bafckeng Sports Academy	60	09-JUN-22	
	Estados Unidos	11	Irene Country Lodge	60	09-JUN-22	
	Argelia	12	Zimbali Lodge	40	10-JUN-22	
	Eslovenia	13	Hyde Park Southern Sun	59	10-JUN-22	
	Alemanha	14	Velmore Hotel	53	10-JUN-22	14-JUN-22
	Australia	15	Kloofzicht Lodge	43	10-JUN-22	
	Servia	16	Sunnyside Park Hotel	45	10-JUN-22	14-JUN-22
	Gana	17	Rode Valley	41	10-JUN-22	
	Holanda	18	Hilton	48	11-JUN-22	15-JUN-22
	Dinamarca	19	Simola Hotel Country	47	11-JUN-22	15-JUN-22
	Japao	20	Fancourt Hotel	53	11-JUN-22	15-JUN-22
	Camaroes	21	Oyster Box	44	11-JUN-22	15-JUN-22
	Italia	22	Leriba Lodge	54	11-JUN-22	15-JUN-22
	Paraguai	23	Woodridge Hotel	56	11-JUN-22	15-JUN-22
	Nova Zelandia	24	Serengati Golf Estate	50	12-JUN-22	16-JUN-22
	Eslovaquia	25	The Villas Luxury Suite	42	12-JUN-22	16-JUN-22
	Brasil	26	The Fairway	60	12-JUN-22	
	Coreia do Norte	27	Protea Hotel Midrand	59	12-JUN-22	
	Costa do Marfim	28	Riverside Hotel Vanderbijlpark	49	12-JUN-22	
	Portugal	29	Valley Lodge	60	12-JUN-22	
	Espanha	30	PUK Sports Village	60	13-JUN-22	17-JUN-22
	Suica	31	Emerald Casino	59	13-JUN-22	
	Honduras	32	Hotel Indeba	53	13-JUN-22	
	Chile	33	Ingwenyama	52	13-JUN-22	17-JUN-22
*/

-- Exercício 4 --------------------------------------------------------------------------------------------------------

/*
	Função: 
*/