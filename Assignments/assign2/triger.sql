CREATE or replace TRIGGER trg_maxbooks
BEFORE INSERT on issue  
FOR EACH ROW
	DECLARE
		BOOKS_ISSUED NUMBER;
		B_STATUS	varchar2(20);

	BEGIN

		SELECT B.status INTO B_STATUS
		FROM Borrower B
		WHERE B.borrower_id = :new.borrower_id;

		SELECT COUNT(I.book_id) INTO BOOKS_ISSUED
		FROM Issue I
		Where I.borrower_id = :new.borrower_id;

		IF (B_STATUS = 'student' AND BOOKS_ISSUED = 2) THEN
			RAISE_APPLICATION_ERROR(-20300, 'Students are not allowed more than 2 Books'); 
		END IF;

		IF (B_STATUS = 'faculty' AND BOOKS_ISSUED = 3) THEN
			RAISE_APPLICATION_ERROR(-20300, 'Faculty members are not allowed more than 3 Books'); 
		END IF;

	END trg_maxbooks;
.
run;

CREATE OR REPLACE TRIGGER trg_issue
	AFTER INSERT ON Issue	
	FOR EACH ROW

	BEGIN
		UPDATE Books B
		SET B.status = 'charged'
		WHERE B.book_id = :new.book_id;

	END trg_issue;
.
run;

CREATE OR REPLACE TRIGGER trg_notissue
	AFTER UPDATE OR DELETE OF return_date ON Issue	
	FOR EACH ROW

	BEGIN
		UPDATE Books B
		SET B.status = 'not charged'
		WHERE B.book_id = :old.book_id;

	END trg_issue;
.
run;
