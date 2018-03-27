CREATE OR REPLACE FUNCTION fun_issue_book(borrower_id IN number, Bk_ID IN number, current_date_ IN date)
	RETURN BINARY_INTEGER is ISSUED BINARY_INTEGER;
	STATUS varchar2(20);
	
	BEGIN	
		SELECT B.status INTO STATUS
		FROM Books B
		WHERE B.book_id = Bk_ID;

		IF (STATUS <> 'charged') THEN
			insert into Issue values(Bk_ID,borrower_id,current_date_,NULL);
			Return(1);
		ELSIF (STATUS = 'charged') THEN
			insert into Pending_request values(Bk_ID,borrower_id,current_date_,NULL);
			Return(0);
		END IF;
	END;
.
run;

CREATE OR REPLACE FUNCTION fun_issue_anyedition(borrower_id IN number, book_title_ IN varchar2, author_name_ IN varchar2 ,current_date_ IN date)
	RETURN BINARY_INTEGER is ISSUED BINARY_INTEGER;
	BOOK_ID_ NUMBER := 0;
	RETURN_DATE DATE := SYSDATE	;
	
	BEGIN
		BEGIN
			SELECT B.book_id INTO BOOK_ID_
			FROM Books B
			WHERE B.book_title = book_title_ AND B.status <> 'charged' AND B.edition IN (
				SELECT MAX(B1.edition) 
				FROM Books B1 
				WHERE B1.book_title = book_title_ AND B1.status <> 'charged');
		EXCEPTION WHEN NO_DATA_FOUND THEN
				SELECT I.book_id INTO BOOK_ID_
				FROM ((select * from ISSUE NATURAL JOIN BOOKS) I)
				WHERE I.book_title = book_title_ AND (I.issue_date+5) IN ( 
						SELECT MIN(I1.issue_date+5) 
						FROM ((select * from ISSUE NATURAL JOIN BOOKS) I1)
						WHERE I1.book_title = book_title_);
				insert into Pending_request values(BOOK_ID_,borrower_id,current_date_,NULL);
				RETURN(0);
		END;

			IF BOOK_ID_ <> 0 THEN
				insert into Issue values(BOOK_ID_,borrower_id,current_date_,NULL);
				Return(1);
			END IF;
	END;
.
run;

CREATE OR REPLACE FUNCTION fun_most_popular(MONTH_ IN number, YEAR_ IN number)
	RETURN varchar2 is popular_book_id varchar2(50);

	BEGIN
		FOR cursor_popular_books IN (
			select I.book_id
			from Issue I
			where extract(year from I.issue_date) = YEAR_ AND extract(month from I.issue_date) = MONTH_
			group by I.book_id
			having count(*) = (
				select max(count(*)) 
				from Issue I1 
				where extract(year from I1.issue_date) = YEAR_ AND extract(month from I1.issue_date) = MONTH_ 
				group by I1.book_id))
		LOOP
			popular_book_id := CONCAT(cursor_popular_books.book_id, CONCAT('  ', popular_book_id));
		END LOOP;

		RETURN popular_book_id;
	END;
.
run;

CREATE OR REPLACE FUNCTION fun_return_book(BOOK_ID_ IN number, CURRENT_DATE_ IN date)
	RETURN BINARY_INTEGER is ISSUED BINARY_INTEGER;
	B_ID NUMBER := 0; -- Initital Junk Value
	BOR_ID NUMBER := 0;

	BEGIN
		BEGIN
		select I.book_id INTO B_ID
		from Issue I
		where I.book_id = BOOK_ID_ AND nvl(TO_CHAR(I.return_date),'0') = '0';

		EXCEPTION WHEN NO_DATA_FOUND THEN
				RETURN(0);
		END;

		IF B_ID <> 0 THEN
			UPDATE Issue I
			SET I.return_date = CURRENT_DATE_
			WHERE I.book_id = B_ID AND nvl(TO_CHAR(I.return_date),'0') = '0';

			BEGIN 
				Select P.book_id, P.requester_id INTO B_ID, BOR_ID
				From Pending_request P
				Where P.book_id = B_ID AND rownum = 1 AND nvl(TO_CHAR(P.issue_date),'0') = '0';

				EXCEPTION WHEN NO_DATA_FOUND THEN
						RETURN(1);
			END;

			UPDATE Pending_request P
			SET P.issue_date = CURRENT_DATE_
			WHERE P.book_id = B_ID AND P.requester_id = BOR_ID AND nvl(TO_CHAR(P.issue_date),'0') = '0';
			
			insert into Issue values(B_ID,BOR_ID,CURRENT_DATE_,NULL);

			RETURN(1);
	
		END IF;

	END;
.
run;

CREATE OR REPLACE FUNCTION fun_renew_book(BORROWER_ID_ IN number, BOOK_ID_ IN number, CURRENT_DATE_ IN date)
RETURN BINARY_INTEGER is ISSUED BINARY_INTEGER;
Book_ID NUMBER := 0;

	BEGIN
		BEGIN
			Select I.book_id INTO Book_ID
			From Issue I
			Where I.book_id = BOOK_ID_ AND borrower_id = BORROWER_ID_ AND nvl(TO_CHAR(I.return_date),'0') = '0';

		EXCEPTION WHEN NO_DATA_FOUND THEN
				RETURN(0);
		END;

		BEGIN
			Select P.book_id INTO Book_ID
			From Pending_request P
			Where P.book_id = BOOK_ID_ AND nvl(TO_CHAR(P.issue_date),'0') = '0';

		EXCEPTION WHEN NO_DATA_FOUND THEN
				UPDATE Issue I
				SET issue_date = CURRENT_DATE_
				Where I.book_id = BOOK_ID_ AND borrower_id = BORROWER_ID_ AND nvl(TO_CHAR(I.return_date),'0') = '0';
				RETURN(1);
		END;

			RETURN(0);
	END;
.
run;
