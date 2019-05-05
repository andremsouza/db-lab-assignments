--CRIACAO SEQUENCIA SeqNFIFA (PARA TODO NFIFA)
CREATE SEQUENCE SeqNFIFA
			INCREMENT BY 1
			START WITH 1
			NOCACHE
			NOCYCLE;

--CRIACAO SEQUENCIA SeqNumero
CREATE SEQUENCE SeqNumero
			INCREMENT BY 1
			START WITH 1
			NOCACHE
			NOCYCLE;

--CRIACAO SEQUENCIA SeqCadastro
CREATE SEQUENCE SeqCadastro
			INCREMENT BY 1
			START WITH 1
			NOCACHE
			NOCYCLE;


--CRIACAO SEQUENCIA SeqOcorrencia
CREATE SEQUENCE SeqOcorrencia
			INCREMENT BY 1
			START WITH 1
			NOCACHE
			NOCYCLE;


--Criacao das Tabelas

CREATE TABLE Estadio (
	Nome       VARCHAR2(100) NOT NULL PRIMARY KEY,
	Cidade     VARCHAR2(60) NOT NULL,
	Capacidade NUMBER(6)
);

CREATE TABLE Equipe (
	Nome         VARCHAR2(100) NOT NULL PRIMARY KEY,
	NComponentes NUMBER(5)
);

CREATE TABLE Hotel (
	Nome       VARCHAR2(100) NOT NULL PRIMARY KEY,
	Cidade     VARCHAR2 (60) NOT NULL
);

	CREATE TABLE Time (
	Pais       VARCHAR2(100) NOT NULL PRIMARY KEY,
	NFIFA      NUMBER NOT NULL,
	EquipeSeg  VARCHAR2(100),
	ProcSeg    VARCHAR2(500),
	Bandeira   BLOB,
	NTotalGols NUMBER(3) DEFAULT 0,
	Tecnico    VARCHAR2(100),
	Grupo      CHAR(1) NOT NULL,
	Pontuacao  NUMBER(3) DEFAULT 0,
	CONSTRAINT UK_Time UNIQUE (NFIFA),
	CONSTRAINT CH_Grupos CHECK (UPPER(Grupo) IN ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H')),
	CONSTRAINT FK_Equipe_Seg FOREIGN KEY (EquipeSeg)
		REFERENCES Equipe(Nome) ON DELETE SET NULL
);

CREATE TABLE OcorrenciaTime (
	Time        VARCHAR2(100) NOT NULL,
	NOcorrencia NUMBER NOT NULL,
	Descricao   VARCHAR2(500) NOT NULL,
	CONSTRAINT PK_Ocorrencia_Time PRIMARY KEY (Time, NOcorrencia),
	CONSTRAINT FK_Ocorrencia_Time FOREIGN KEY (Time)
		 REFERENCES Time(Pais) ON DELETE CASCADE
);

CREATE TABLE Hospeda (
	Time       VARCHAR2(100) NOT NULL,
	Hotel      VARCHAR2(100) NOT NULL,
	NDelegacao NUMBER(3),
	CONSTRAINT PK_Hospeda PRIMARY KEY (Time, Hotel),
	CONSTRAINT FK_Hospeda_Time FOREIGN KEY (Time)
		REFERENCES Time(Pais) ON DELETE CASCADE,
	CONSTRAINT FK_Hospeda_Hotel FOREIGN KEY (Hotel)
		REFERENCES Hotel(Nome)ON DELETE CASCADE
);

CREATE TABLE Dista (
	Hotel       VARCHAR2(100) NOT NULL,
	Estadio     VARCHAR2(100) NOT NULL,
	Distancia   NUMBER(8,1) NOT NULL,
	CONSTRAINT PK_Dista PRIMARY KEY (Hotel, Estadio),
	CONSTRAINT FK_Dista_Hotel FOREIGN KEY (Hotel)
		REFERENCES Hotel(Nome) ON DELETE CASCADE,
	CONSTRAINT FK_Dista_Estadio FOREIGN KEY (Estadio)
		REFERENCES Estadio (Nome) ON DELETE CASCADE
);

CREATE TABLE PeriodoHosp (
	Time       VARCHAR2(100) NOT NULL,
	Hotel      VARCHAR2(100) NOT NULL,
	DtaEntrada DATE NOT NULL,
	DtaSaida   DATE,
	CONSTRAINT PK_PeriodoHosp PRIMARY KEY (Time, Hotel, DtaEntrada),
	CONSTRAINT FK_PeriodoHosp FOREIGN KEY (Time, Hotel)
		REFERENCES Hospeda(Time, Hotel) ON DELETE CASCADE
);

CREATE TABLE Emissora (
	Nome       VARCHAR2(100) NOT NULL,
	Pais       VARCHAR2(60) NOT NULL,
	CONSTRAINT PK_Emissora PRIMARY KEY (Nome, Pais)
);

CREATE TABLE PaisTransm (
	NomeEmissora VARCHAR2(100) NOT NULL,
	PaisEmissora VARCHAR2(60) NOT NULL,
	PaisTransm   VARCHAR2(60) NOT NULL,
	CONSTRAINT PK_PaisTransm PRIMARY KEY (NomeEmissora, PaisEmissora, PaisTransm),
	CONSTRAINT FK_PaisTransm FOREIGN KEY (NomeEmissora, PaisEmissora)
		REFERENCES Emissora(Nome, Pais) ON DELETE CASCADE
);

CREATE TABLE Profissional (
	NFIFA     NUMBER NOT NULL PRIMARY KEY,
	Nome      VARCHAR2(100) NOT NULL,
	Profissao VARCHAR2(30)
);

CREATE TABLE Acesso (
	NFIFAProfissional NUMBER NOT NULL,
	Acesso            VARCHAR2(30) NOT NULL,
	CONSTRAINT PK_Acesso PRIMARY KEY (NFIFAProfissional, Acesso),
	CONSTRAINT FK_Acesso FOREIGN KEY (NFIFAProfissional)
		REFERENCES Profissional(NFIFA) ON DELETE CASCADE
);

CREATE TABLE Emprega (
	NomeEmissora      VARCHAR2(100) NOT NULL,
	PaisEmissora	    VARCHAR2(60) NOT NULL,
	NFIFAProfissional NUMBER NOT NULL,
	CONSTRAINT PK_Emprega PRIMARY KEY (NomeEmissora, PaisEmissora, NFIFAProfissional),
	CONSTRAINT FK_Emprega_Emissora FOREIGN KEY (NomeEmissora, PaisEmissora)
		REFERENCES Emissora(Nome, Pais) ON DELETE CASCADE,
	CONSTRAINT FK_Emprega_Profissional FOREIGN KEY (NFIFAProfissional)
		REFERENCES Profissional(NFIFA) ON DELETE CASCADE
);

CREATE TABLE Treina (
	Time      VARCHAR2(100) NOT NULL,
	Estadio	VARCHAR2(100) NOT NULL,
	DtaTreino DATE NOT NULL,
	CONSTRAINT PK_Treina PRIMARY KEY (Time, Estadio, DtaTreino),
	CONSTRAINT FK_Treina_Time FOREIGN KEY (Time)
		REFERENCES Time(Pais) ON DELETE CASCADE,
	CONSTRAINT FK_Treina_Estadio FOREIGN KEY (Estadio)
		REFERENCES Estadio(Nome) ON DELETE CASCADE
);

CREATE TABLE Seguranca (
	NCadastro NUMBER NOT NULL PRIMARY KEY,
	Nome      VARCHAR2(100) NOT NULL,
	Funcao    VARCHAR2(50),
	Turno     CHAR(5),
	Equipe	VARCHAR2(100),
	CONSTRAINT FK_Seguranca FOREIGN KEY (Equipe)
		 REFERENCES Equipe(Nome) ON DELETE SET NULL,
	CONSTRAINT CK_Seguranca_Turno CHECK (UPPER(Turno) IN ('MANHA', 'TARDE', 'NOITE'))
);

CREATE TABLE Jogo (
	Numero        NUMBER NOT NULL PRIMARY KEY,
	Fase	        VARCHAR2(20) NOT NULL,
	Time1         VARCHAR2(100) NOT NULL,
	Time2         VARCHAR2(100) NOT NULL,
	DataHora      DATE NOT NULL,
	NGols1	    NUMBER(2) DEFAULT 0,
	NGols2        NUMBER(2) DEFAULT 0,
	Estadio       VARCHAR2(100) NOT NULL,
	Arbitro       VARCHAR2(100) NOT NULL,
	Assistente1   VARCHAR2(100) NOT NULL,
	Assistente2   VARCHAR2(100) NOT NULL,
	QuartoArbitro VARCHAR2(100) NOT NULL,
	CONSTRAINT FK_Jogo_Time1 FOREIGN KEY (Time1)
		REFERENCES Time(Pais) ON DELETE CASCADE,
	CONSTRAINT FK_Jogo_Time2 FOREIGN KEY (Time2)
		REFERENCES Time(Pais) ON DELETE CASCADE,
	CONSTRAINT FK_Jogo_Estadio FOREIGN KEY (Estadio)
		REFERENCES Estadio(Nome) ON DELETE CASCADE,
	CONSTRAINT CK_Jogo_Fase CHECK (UPPER(Fase) IN ('PRIMEIRA FASE', 'OITAVAS-DE-FINAL', 'QUARTAS-DE-FINAL', 'SEMIFINAIS', 'TERCEIRO LUGAR', 'FINAL'))
);

CREATE TABLE Transmite (
	Jogo              NUMBER NOT NULL,
	NomeEmissora      VARCHAR2(100) NOT NULL,
	PaisEmissora	    VARCHAR2(100) NOT NULL,
	TV                CHAR(1) NOT NULL,
	Radio             CHAR(1) NOT NULL,
	Internet          CHAR(1) NOT NULL,
	CONSTRAINT PK_Transmite PRIMARY KEY (Jogo, NomeEmissora, PaisEmissora),
	CONSTRAINT FK_Transmite_Jogo FOREIGN KEY (Jogo)
		REFERENCES Jogo(Numero) ON DELETE CASCADE,
	CONSTRAINT FK_Transmite_Emissora FOREIGN KEY (NomeEmissora, PaisEmissora)
		REFERENCES Emissora(Nome, Pais) ON DELETE CASCADE,
	CONSTRAINT CK_Transmite_TV CHECK (UPPER(TV) IN ('S', 'N')),
	CONSTRAINT CK_Transmite_Radio CHECK (UPPER(Radio) IN ('S', 'N')),
	CONSTRAINT CK_Transmite_Internet CHECK (UPPER(Internet) IN ('S', 'N'))
);

CREATE TABLE Trabalha (
	Equipe  VARCHAR2(100) NOT NULL,
	Jogo    NUMBER NOT NULL,
	ProcSeg VARCHAR2(500) NOT NULL,
	CONSTRAINT PK_Trabalha PRIMARY KEY (Equipe, Jogo),
	CONSTRAINT FK_Trabalha_Equipe FOREIGN KEY (Equipe)
		 REFERENCES Equipe(Nome) ON DELETE CASCADE,
	CONSTRAINT FK_Trabalha_Jogo FOREIGN KEY (Jogo)
		 REFERENCES Jogo(Numero) ON DELETE CASCADE
);

CREATE TABLE OcorrenciaTrabalha (
	Equipe     VARCHAR2(100) NOT NULL,
	Jogo       NUMBER NOT NULL,
	NOcorrencia NUMBER NOT NULL,
	Descricao VARCHAR2(200) NOT NULL,
	CONSTRAINT PK_Ocorrencia_Trabalha PRIMARY KEY (Equipe, Jogo, NOcorrencia),
	CONSTRAINT FK_Ocorrencia_Trabalha FOREIGN KEY (Equipe, Jogo)
		 REFERENCES Trabalha(Equipe, Jogo) ON DELETE CASCADE
);

CREATE TABLE Jogador (
	NFIFA      NUMBER NOT NULL PRIMARY KEY,
	Nome       VARCHAR2(100) NOT NULL,
	Apelido    VARCHAR2(30),
	DtaNasc    DATE,
	Posicao    VARCHAR2(100) NOT NULL,
	Capitao    CHAR(1) NOT NULL,
	Time       VARCHAR2(100) NOT NULL,
	CONSTRAINT FK_Jogador FOREIGN KEY (Time)
		REFERENCES Time(Pais) ON DELETE CASCADE,
	 CONSTRAINT CK_Jogador_Capitao CHECK ((UPPER(Capitao) IN ('S', 'N')))
);

CREATE TABLE Participa (
	Jogador     NUMBER NOT NULL,
	Jogo        NUMBER NOT NULL,
	HoraEntrada DATE,
	HoraSaida   DATE,
	NCartaoAm   NUMBER(2) DEFAULT 0,
	NCartaoVerm NUMBER(2) DEFAULT 0,
	NFaltas     NUMBER(2) DEFAULT 0,
	NPenaltes   NUMBER(2) DEFAULT 0,
	NGols       NUMBER(2) DEFAULT 0,
	Escalacao   CHAR(7)   NOT NULL,
	CONSTRAINT PK_Participa PRIMARY KEY (Jogador, Jogo),
	CONSTRAINT FK_Participa_Jogador FOREIGN KEY (Jogador)
		REFERENCES Jogador(NFIFA) ON DELETE CASCADE,
	CONSTRAINT FK_Participa_Jogo FOREIGN KEY (Jogo)
		REFERENCES Jogo(Numero) ON DELETE CASCADE,
	CONSTRAINT CK_Participa_Escalacao CHECK ((UPPER(Escalacao) IN ('TITULAR', 'RESERVA')))
);