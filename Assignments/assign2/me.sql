set serveroutput on size 30000;
set feedback off;
-- STEP 1 + STEP 2

@dropall
@createtable
@populate
@triger
@procedures
@functions
spool myoutputfile.txt
@procedures


-- STEP 3
-- DECLARE
--    c number;
-- BEGIN
--    c := fun_issue_book(3, 1, sysdate);
--    dbms_output.put_line('Issued / Not Issued: ' || c);
-- END;
-- /

-- DECLARE
--    c number;
-- BEGIN
--    c := fun_issue_book(3, 2, sysdate);
--    dbms_output.put_line('Issued / Not Issued: ' || c);
-- END;
-- /

-- DECLARE
--    c number;
-- BEGIN
--    c := fun_issue_book(3, 1, sysdate);
--    dbms_output.put_line('Issued / Not Issued: ' || c);
-- END;
-- /

-- DECLARE
--    c number;
-- BEGIN
--    c := fun_issue_book(5, 1, sysdate);
--    dbms_output.put_line('Issued / Not Issued: ' || c);
-- END;
-- /

-- STEP 4
DECLARE
   c number;
BEGIN
	c := fun_issue_anyedition(2, 'DATA MANAGEMENT','C.J DATES', TO_DATE('03/03/2015', 'mm/dd/yyyy'));
	dbms_output.put_line('Issued / Not Issued: ' || c);
END;
/

DECLARE
   c number;
BEGIN
	c := fun_issue_anyedition(4, 'CALCULUS','H. ANTON', TO_DATE('03/04/2015', 'mm/dd/yyyy'));
	dbms_output.put_line('Issued / Not Issued: ' || c);
END;
/

DECLARE
   c number;
BEGIN
	c := fun_issue_anyedition(5, 'ORACLE','ORACLE PRESS', TO_DATE('03/04/2015', 'mm/dd/yyyy'));   
	dbms_output.put_line('Issued / Not Issued: ' || c);
END;
/

DECLARE
   c number;
BEGIN
	c := fun_issue_anyedition(10, 'IEEE MULTIMEDIA','IEEE', TO_DATE('02/27/2015', 'mm/dd/yyyy'));
	dbms_output.put_line('Issued / Not Issued: ' || c);
END;
/

DECLARE
   c number;
BEGIN
	c := fun_issue_anyedition(2, 'MIS MANAGEMENT','C.J CATES', TO_DATE('05/03/2015', 'mm/dd/yyyy'));
	dbms_output.put_line('Issued / Not Issued: ' || c);
END;
/

DECLARE
   c number;
BEGIN
	c := fun_issue_anyedition(4, 'CALCULUS II','H. ANTON', TO_DATE('03/04/2015', 'mm/dd/yyyy'));
	dbms_output.put_line('Issued / Not Issued: ' || c);
END;
/


DECLARE
   c number;
BEGIN
	c := fun_issue_anyedition(10, 'ORACLE','ORACLE PRESS', TO_DATE('03/04/2015', 'mm/dd/yyyy'));
	dbms_output.put_line('Issued / Not Issued: ' || c);
END;
/

DECLARE
   c number;
BEGIN
	c := fun_issue_anyedition(5, 'IEEE MULTIMEDIA','IEEE', TO_DATE('02/26/2015', 'mm/dd/yyyy'));
	dbms_output.put_line('Issued / Not Issued: ' || c);
END;
/

DECLARE
   c number;
BEGIN
	c := fun_issue_anyedition(2, 'DATA STRUCTURE','W. GATES', TO_DATE('03/03/2015', 'mm/dd/yyyy'));
	dbms_output.put_line('Issued / Not Issued: ' || c);
END;
/

DECLARE
   c number;
BEGIN
	c := fun_issue_anyedition(4, 'CALCULUS III','H. ANTON', TO_DATE('04/04/2015', 'mm/dd/yyyy'));
	dbms_output.put_line('Issued / Not Issued: ' || c);	
END;
/

DECLARE
   c number;
BEGIN
	c := fun_issue_anyedition(11, 'ORACLE','ORACLE PRESS', TO_DATE('03/08/2015', 'mm/dd/yyyy'));
	dbms_output.put_line('Issued / Not Issued: ' || c);
END;
/

DECLARE
   c number;
BEGIN
	c := fun_issue_anyedition(6, 'IEEE MULTIMEDIA','IEEE', TO_DATE('02/17/2015', 'mm/dd/yyyy'));
	dbms_output.put_line('Issued / Not Issued: ' || c);
END;
/

-- STEP 5
execute pro_print_borrower;
-- STEP 6
execute pro_print_fine(sysdate);

select * from issue;

-- STEP 7
DECLARE
   c number;
BEGIN
	c := fun_return_book(1, sysdate);
	dbms_output.put_line('Returned / Not Returned: ' || c);
END;
/

DECLARE
   c number;
BEGIN
	c := fun_return_book(2, sysdate);
	dbms_output.put_line('Returned / Not Returned: ' || c);
END;
/

DECLARE
   c number;
BEGIN
	c := fun_return_book(4, sysdate);
	dbms_output.put_line('Returned / Not Returned: ' || c);
END;
/

DECLARE
   c number;
BEGIN
	c := fun_return_book(10, sysdate);
	dbms_output.put_line('Returned / Not Returned: ' || c);
END;
/
select * from issue;
-- STEP 8
execute pro_listborr_mon(5,'MAR',2015);
-- STEP 9
execute pro_listborr_mon(4,'FEB',2015);
-- STEP 10
execute pro_list_borr;
-- STEP 11
execute pro_list_popular;

-- STEP 12
execute AVG_TIME_WAITING;

-- STEP 13
execute MAX_WAITING;

@drop_fun_pro