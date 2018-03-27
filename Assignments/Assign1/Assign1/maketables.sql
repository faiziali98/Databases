
CREATE TABLE CLASS (
  cnum varchar2(10) NOT NULL,
  meets_at date,
  room varchar2(10),
  fid number,
  PRIMARY KEY (cnum)
);

CREATE TABLE ENROLLED (
  cnum varchar2(10) NOT NULL,
  sid number NOT NULL,
  PRIMARY KEY (cnum,sid)
);

CREATE TABLE FACULTY (
  fid number NOT NULL,
  fname varchar2(20),
  dept varchar2(20),
  PRIMARY KEY (fid)
);

CREATE TABLE PREREQUISITE (
  cnum varchar2(10) NOT NULL,
  prereq varchar2(10) NOT NULL,
  PRIMARY KEY (cnum,prereq)
);


CREATE TABLE STUDENT (
  sid number NOT NULL,
  sname varchar2(15),
  major varchar2(10),
  slevel varchar2(10),
  age number,
  PRIMARY KEY (sid)
); 
