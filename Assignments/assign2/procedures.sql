set serveroutput on size 300000;

CREATE OR REPLACE PROCEDURE pro_print_borrower
AS
BEGIN
	dbms_output.put_line('Borrower Name    Book Title    <= 5 days    <= 10 days    <= 15 days    >15 days'); -- 4 Spaces
	dbms_output.put_line('-------------    ----------    ---------    ----------    ----------    --------');

	FOR cursor_print IN (SELECT name, book_title, TRUNC(round(SYSDATE - issue_date),0) AS Issued_Time 
		FROM ((select * from Issue NATURAL JOIN Books) K JOIN Borrower B on K.borrower_id = B.borrower_id)
		Where nvl(TO_CHAR(return_date),'0') = '0')
	Loop
		
		IF (cursor_print.Issued_Time <= 5) THEN
			dbms_output.put_line(cursor_print.name || '  ' || cursor_print.book_title || '      ' || cursor_print.Issued_Time);
		ELSIF (cursor_print.Issued_Time <= 10) THEN
			dbms_output.put_line(cursor_print.name || '  ' || cursor_print.book_title || '                ' || cursor_print.Issued_Time);
		ELSIF (cursor_print.Issued_Time <= 15) THEN
			dbms_output.put_line(cursor_print.name || '  ' || cursor_print.book_title || '                                ' || cursor_print.Issued_Time);
		ELSIF (cursor_print.Issued_Time > 15) THEN
			dbms_output.put_line(cursor_print.name || '  ' || cursor_print.book_title || '                                                ' || cursor_print.Issued_Time);
		END IF;

	End Loop;
END;
.
run;

CREATE OR REPLACE PROCEDURE pro_print_fine(current_date_ IN date)
AS
BEGIN
	dbms_output.put_line('Borrower Name          Book ID          Issue Date          Fine');
	dbms_output.put_line('-------------          -------          ----------          ----');

	FOR cursor_print IN (SELECT name, book_id, issue_date, TRUNC(round(current_date_ - 5 - issue_date),0) AS days 
		FROM ((select * from Issue NATURAL JOIN Books) K JOIN Borrower B on K.borrower_id = B.borrower_id)
		Where nvl(TO_CHAR(return_date),'0') = '0')
	Loop

		IF (cursor_print.days > 5) THEN
			dbms_output.put_line(cursor_print.name || CHR(9) || CHR(9) || cursor_print.book_id || CHR(9) || CHR(9) || cursor_print.issue_date || CHR(9) || CHR(9) ||  (cursor_print.days*5));
		END IF;

	END LOOP;
END;
.
run;

CREATE OR REPLACE PROCEDURE pro_listborr_mon(borrower_id_ IN number, MONTH_ IN varchar2, YEAR_ IN number)
AS
BEGIN
	dbms_output.put_line('Borower ID   Borrower Name   Book ID   Book Title   Issue Date   Return Date');
	dbms_output.put_line('----------   -------------   -------   ----------   ----------   -----------');

	FOR cursor_print IN (SELECT k.borrower_id, name, book_id, book_title, issue_date, return_date 
		FROM ((select * from Issue NATURAL JOIN Books) K JOIN Borrower B on K.borrower_id = B.borrower_id)
		Where extract(year from issue_date) = YEAR_ AND k.borrower_id=borrower_id_
		AND issue_date like ('%'||MONTH_||'%'))
	LOOP
		dbms_output.put_line(cursor_print.borrower_id || CHR(9) || cursor_print.name || CHR(9) || cursor_print.book_id || CHR(9) || cursor_print.book_title || CHR(9) || cursor_print.issue_date || CHR(9) || cursor_print.return_date);
	END Loop;
END;
.
run;

CREATE OR REPLACE PROCEDURE pro_list_borr
AS
BEGIN
	dbms_output.put_line('Borrower Name          Book ID          Issue Date');
	dbms_output.put_line('-------------          -------          ----------');

	FOR cursor_print IN (SELECT name, book_id, issue_date 
		FROM Issue I JOIN Borrower B on I.borrower_id = B.borrower_id 
		Where nvl(TO_CHAR(return_date),'0') = '0')
	LOOP
		dbms_output.put_line(cursor_print.name || CHR(9) || CHR(9) || CHR(9) || cursor_print.book_id || CHR(9) || cursor_print.issue_date);
	END LOOP;
END;
.
run;

CREATE OR REPLACE PROCEDURE pro_list_popular
AS
	Author_Name varchar2(30);
	Number_Editions number := 0;
BEGIN
		dbms_output.put_line('Month    Year        Author Name        No. of Editions');
		dbms_output.put_line('-----    ----        -----------        ---------------');

		FOR cursor_popular_books IN (
			SELECT STATS_MODE(book_id) as BOOK_ID_, extract(month from trunc(issue_date, 'MM')) as MONTH,  extract(year from trunc(issue_date, 'YYYY')) as YEAR
			FROM Issue NATURAL JOIN Books 
			GROUP BY trunc(issue_date, 'YYYY'), trunc(issue_date, 'MM'))
		LOOP
			select name INTO Author_Name
			from Books NATURAL JOIN Author 
			where book_id = cursor_popular_books.BOOK_ID_;

			select count(*) INTO Number_Editions
			from Books B
			where B.book_title = (select B1.book_title From Books B1 Where B1.book_id = cursor_popular_books.BOOK_ID_);

			dbms_output.put_line(cursor_popular_books.MONTH || CHR(9) || cursor_popular_books.YEAR || CHR(9) || CHR(9) || Author_Name || CHR(9) || CHR(9) || Number_Editions);

		END LOOP;
	END;
.
run;

CREATE OR REPLACE PROCEDURE AVG_TIME_WAITING
AS
	Total_Time number := 0;
	counter number := 0;

BEGIN
		FOR cursor_Time IN (select round(P.issue_date - P.request_date,0) as WAIT_TIME 
			from pending_request P 
			where nvl(TO_CHAR(P.issue_date),'0') <> '0')
		LOOP
			Total_Time := Total_Time + cursor_Time.WAIT_TIME;
			counter := counter + 1;
		END LOOP;
			dbms_output.put_line('Average Time Waiting: ' || Total_Time / counter);
	END;
.
run;

CREATE OR REPLACE PROCEDURE MAX_WAITING
AS
	Max_Time number := 0;
	BORR_ID number := 0;
	B_Name varchar2(100);

BEGIN
		FOR cursor_Time IN (select P.requester_id, round(P.issue_date - P.request_date,0) as WAIT_TIME 
			from pending_request P 
			where nvl(TO_CHAR(P.issue_date),'0') <> '0')
		LOOP
			IF (cursor_Time.WAIT_TIME > Max_Time) THEN
				Max_Time := cursor_Time.WAIT_TIME;
				BORR_ID := cursor_Time.requester_id;
			END IF;

		END LOOP;
			select B.name into B_Name
			from Borrower B
			where B.borrower_id = BORR_ID;

			dbms_output.put_line('Borrower with maximum waiting Time: ' || B_Name || ' (' || Borr_ID || ')');
	END;
.
run;