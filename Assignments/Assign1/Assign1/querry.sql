set serveroutput on;
set feedback off;

spool myoutputfile.txt


exec DBMS_OUTPUT.PUT_LINE('Query #1');
SELECT MAX(age) FROM (student s join enrolled e ON s.sid=e.sid join class c 
	ON c.cnum=e.cnum join faculty f ON f.fid=c.fid) WHERE major='CS' OR fname='Prof. Brown';

exec DBMS_OUTPUT.PUT_LINE('Query #2');
SELECT C.cnum FROM Class C WHERE C.room = '115' 
							OR C.cnum IN (SELECT E.cnum FROM Enrolled E
											GROUP BY E.cnum
											HAVING COUNT (*) >= 5);
exec DBMS_OUTPUT.PUT_LINE('Query #3');
SELECT S.sname FROM Student S WHERE S.sid IN (SELECT E1.sid
												FROM Enrolled E1, Enrolled E2, Class C1, Class C2
												WHERE E1.sid = E2.sid AND E1.cnum <> E2.cnum
												AND E1.cnum = C1.cnum
												AND E2.cnum = C2.cnum AND C1.meets_at = C2.meets_at); 
exec DBMS_OUTPUT.PUT_LINE('Query #4');
SELECT F.fname FROM Faculty F WHERE NOT EXISTS (
						( SELECT DISTINCT room FROM Class C ) MINUS
						(SELECT room FROM Class C1 WHERE F.fid=C1.fid));

exec DBMS_OUTPUT.PUT_LINE('Query #5');
SELECT fname FROM (Faculty NATURAL JOIN Class NATURAL JOIN Enrolled) 
					GROUP BY fname HAVING COUNT(*)>=8;

exec DBMS_OUTPUT.PUT_LINE('Query #6');
SELECT S.slevel, AVG(age) FROM student S WHERE S.slevel<>'JR' GROUP BY S.slevel;

exec DBMS_OUTPUT.PUT_LINE('Query #7');
SELECT sid,sname FROM student NATURAL JOIN Enrolled GROUP BY sid,sname
			HAVING COUNT(*)=(SELECT MAX(COUNT(*)) FROM student NATURAL JOIN Enrolled GROUP BY sid,sname);

exec DBMS_OUTPUT.PUT_LINE('Query #8');
SELECT sname FROM student WHERE  sid NOT IN (SELECT E.sid FROM Enrolled E);	

exec DBMS_OUTPUT.PUT_LINE('Query #9');
SELECT S.age, S.slevel FROM Student S GROUP BY S.age, S.slevel HAVING S.slevel IN (
				SELECT S1.slevel FROM Student S1  WHERE S.age= S1.age GROUP BY S1.slevel,S1.age HAVING COUNT(*)>=ALL (
				SELECT COUNT(*) FROM Student S2  WHERE S1.age= S2.age GROUP BY S2.slevel,S2.age));

exec DBMS_OUTPUT.PUT_LINE('Query #10');
SELECT TE.AVG-TC.AVG AS DIFFERENCE FROM(
SELECT SUM(TS.student)/SUM(TF.Fac) as AVG FROM (SELECT COUNT(*) as Fac FROM Faculty F WHERE dept='EE') TF, 
			(SELECT COUNT(*) as student FROM (Faculty NATURAL JOIN Class NATURAL JOIN Enrolled) WHERE dept='EE') TS) TE,(
SELECT SUM(TS.student)/SUM(TF.Fac) as AVG FROM (SELECT COUNT(*) as Fac FROM Faculty F WHERE dept='CS') TF, 
			(SELECT COUNT(*) as student FROM (Faculty NATURAL JOIN Class NATURAL JOIN Enrolled) WHERE dept='CS') TS) TC;

exec DBMS_OUTPUT.PUT_LINE('Query #11');
SELECT fname,COUNT(*) as students FROM (Faculty NATURAL JOIN Class NATURAL JOIN Enrolled) GROUP BY fname 
	HAVING COUNT(*)>ALL (SELECT AVG(temp.students) AS AVGEE FROM 
		(SELECT fname,COUNT(*) as students FROM (Faculty NATURAL JOIN Class NATURAL JOIN Enrolled) GROUP BY fname) temp, Faculty F
					WHERE F.fname=temp.fname AND F.dept='EE');

exec DBMS_OUTPUT.PUT_LINE('Query #12 (Giving the name of the prof and class he can teach even if he cant teach every class of wasfi)');
SELECT T.fname AS Professor, Q.cnum AS can_teach, Q.meets_at AS at FROM (
	SELECT fname FROM (SELECT * FROM (Faculty NATURAL JOIN Class)) WHERE dept='EE' AND meets_at NOT IN (
		SELECT meets_at FROM (Faculty NATURAL JOIN Class) WHERE fname like '%Wasfi')) T,
	(SELECT cnum,meets_at FROM (Faculty NATURAL JOIN Class) WHERE fname like '%Wasfi') Q
	WHERE Q.meets_at NOT IN (SELECT meets_at FROM (Faculty NATURAL JOIN Class) WHERE fname =T.fname);

exec DBMS_OUTPUT.PUT_LINE('Query #13');
SELECT sname,cnum FROM (Student NATURAL JOIN Enrolled) WHERE cnum IN (
SELECT C.cnum FROM Class C WHERE C.cnum NOT IN (SELECT cnum from prerequisite)); 

exec DBMS_OUTPUT.PUT_LINE('Query #14');
SELECT * FROM ( SELECT * from Class NATURAL JOIN prerequisite) T WHERE T.meets_at NOT IN(
				SELECT meets_at FROM Class C WHERE C.cnum=T.prereq);

exec DBMS_OUTPUT.PUT_LINE('Query #15');
SELECT T.fname FROM ( SELECT * from Class NATURAL JOIN prerequisite NATURAL JOIN Faculty) T WHERE T.fid IN(
				SELECT fid from Class NATURAL JOIN prerequisite WHERE cnum=T.prereq);

exec DBMS_OUTPUT.PUT_LINE('Query #16 (Assuming the extended prerequisite is not the immediate prerequisite)');
SELECT P.cnum FROM prerequisite P WHERE P.prereq IN(
				SELECT P1.cnum FROM prerequisite P1 WHERE P1.prereq NOT IN (
				SELECT P2.cnum FROM prerequisite P2))
UNION
SELECT P.cnum FROM prerequisite P WHERE P.prereq IN(
			SELECT P1.cnum FROM prerequisite P1 WHERE P1.prereq IN (
			SELECT P2.cnum FROM prerequisite P2 WHERE P2.prereq NOT IN (
			SELECT P3.cnum FROM prerequisite P3)))
UNION
SELECT P.cnum FROM prerequisite P WHERE P.prereq IN(
			SELECT P1.cnum FROM prerequisite P1 WHERE P1.prereq IN (
			SELECT P2.cnum FROM prerequisite P2 WHERE P2.prereq IN (
			SELECT P3.cnum FROM prerequisite P3 WHERE P3.prereq NOT IN (
			SELECT P4.cnum FROM prerequisite P4))));

exec DBMS_OUTPUT.PUT_LINE('Query #17 (Assuming the extended prerequisite is not the immediate prerequisite)');
SELECT S.sname,T.cnum,P3.prereq AS Extn_Prereq FROM (
		SELECT P.cnum,P.prereq FROM prerequisite P WHERE P.prereq IN(
				SELECT P1.cnum FROM prerequisite P1 WHERE P1.prereq NOT IN (
				SELECT P2.cnum FROM prerequisite P2))) T,prerequisite P3,(SELECT * FROM (student NATURAL JOIN Enrolled)) S  
		WHERE P3.cnum=T.prereq AND S.cnum=T.cnum;
		
spool off;
CREATE VIEW VIEWA
AS SELECT fid, fname, cnum FROM (Faculty NATURAL JOIN Class);

CREATE VIEW VIEWB
AS SELECT sid, sname, cnum FROM (Student NATURAL JOIN Enrolled) GROUP BY sid,sname,cnum;