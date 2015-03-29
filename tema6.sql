DROP TABLE DEPT
/
CREATE TABLE DEPT 
    (DEPTNO NUMBER(2) NOT NULL, 
	DNAME CHAR(14) NULL, 
	LOC CHAR(13) NULL ) 
/
DROP TABLE EMP
/
CREATE TABLE EMP 
	(EMPNO NUMBER(4) NOT NULL, 
	ENAME CHAR(10) NULL, 
	JOB CHAR(9) NULL, 
	MGR NUMBER(4) NULL, 
	HIREDATE DATE NULL , 
	SAL NUMBER(7,2) NULL, 
	COMM NUMBER(7,2) NULL, 
	DEPTNO NUMBER(2))
/
INSERT INTO DEPT VALUES 
	(10,'ACCOUNTING','NEW YORK')
/
INSERT INTO DEPT VALUES (20,'RESEARCH','DALLAS')
/
INSERT INTO DEPT VALUES 
	(30,'SALES','CHICAGO')
/
INSERT INTO DEPT VALUES 
	(40,'OPERATIONS','BOSTON')
/
INSERT INTO EMP VALUES 
(7369,'SMITH','CLERK',7902, TO_DATE('17/12/1980', 'dd/mm/yyyy'),800,NULL,20)
/
INSERT INTO EMP VALUES 
(7499,'ALLEN','SALESMAN',7698, TO_DATE('20/2/1981', 'dd/mm/yyyy'),1600,300,30)
/
INSERT INTO EMP VALUES 
(7521,'WARD','SALESMAN',7698, TO_DATE('22/2/1981', 'dd/mm/yyyy'),1250,500,30)
/
INSERT INTO EMP VALUES 
(7566,'JONES','MANAGER',7839, TO_DATE('2/4/1981', 'dd/mm/yyyy'),2975,NULL,20)
/
INSERT INTO EMP VALUES 
(7654,'MARTIN','SALESMAN',7698, TO_DATE('28/9/1981', 'dd/mm/yyyy'),1250,1400,30)
/
INSERT INTO EMP VALUES 
(7698,'BLAKE','MANAGER',7839, TO_DATE('1/5/1981', 'dd/mm/yyyy'),2850,NULL,30)
/
INSERT INTO EMP VALUES 
(7782,'CLARK','MANAGER',7839, TO_DATE('9/6/1981', 'dd/mm/yyyy'),2450,NULL,10)
/
INSERT INTO EMP VALUES 
(7788,'SCOTT','ANALYST',7566, TO_DATE('13/7/1987', 'dd/mm/yyyy'),3000,NULL,20)
/
INSERT INTO EMP VALUES
(7839,'KING','PRESIDENT',NULL, TO_DATE('17/11/1981', 'dd/mm/yyyy'),5000,NULL,10)
/
INSERT INTO EMP VALUES 
(7844,'TURNER','SALESMAN',7698, TO_DATE('8/9/1981', 'dd/mm/yyyy'),1500,0,30)
/
INSERT INTO EMP VALUES 
(7876,'ADAMS','CLERK',7788,TO_DATE('13/7/1987', 'dd/mm/yyyy'),1100,NULL,20)
/
INSERT INTO EMP VALUES 
(7900,'JAMES','CLERK',7698,TO_DATE('3/12/1981', 'dd/mm/yyyy'),950,NULL,30)
/
INSERT INTO EMP VALUES 
(7902,'FORD','ANALYST',7566,TO_DATE('3/12/1981', 'dd/mm/yyyy'),3000,NULL,20)
/
INSERT INTO EMP VALUES 
(7934,'MILLER','CLERK',7782,TO_DATE('23/1/1982', 'dd/mm/yyyy'),1300,NULL,10)
/
DROP TABLE BONUS
/
CREATE TABLE BONUS 
	( 
	ENAME CHAR(10) NULL, 
	JOB CHAR(9) NULL, 
	SAL NUMBER NULL, 
	COMM NUMBER 
	) 
/
DROP TABLE salgrade;

CREATE TABLE salgrade(
	grade		NUMBER( 5 ),
	losal		NUMBER( 7 ),
	hisal		NUMBER( 7 ),
	tax			NUMBER( 5, 2 ),
	seniority	NUMBER( 2 ));

INSERT INTO salgrade VALUES( 1,  700, 1200, 0.10, 2 );
INSERT INTO salgrade VALUES( 2, 1201, 1400, 0.15, 3 );
INSERT INTO salgrade VALUES( 3, 1401, 2000, 0.20, 4 );
INSERT INTO salgrade VALUES( 4, 2001, 3000, 0.35, 3 );
INSERT INTO salgrade VALUES( 5, 3001, 9999, 0.60, 0 );

COMMIT;

--select * from dept;
--select * from emp order by deptno
--order by job;

/
set serveroutput on;
/
CREATE OR REPLACE DIRECTORY BAU AS 'C:\test';
GRANT READ ON DIRECTORY CTEST TO PUBLIC; /
create or replace package tema6 is
 

procedure adauga(nume emp.ename%type,salariu emp.sal%type, slujba emp.job%type,idSef emp.mgr%type);
procedure concediaza (ida emp.empno%type);
procedure concediaza (ida emp.ename%type);
procedure adaugaDep (nume dept.dname%type,lo dept.loc%type);
procedure afiseaza(scrie emp.ename%type);
end tema6;
   /
 create or replace package body tema6 is
 
  procedure adauga(nume emp.ename%type,salariu emp.sal%type, slujba emp.job%type,idSef emp.mgr%type) is
      nuExista Exception;
      cursor angajati is
          select deptno from
                (select count(*)aa,deptno
                      from emp
                      where job=slujba
                      group by deptno 
                      order by aa)
            where rownum<2;
      cursor putini is
          select deptno from(
                select count(*)aa,deptno
                      from emp
                      group by deptno 
                      order by aa)
          where rownum<2;
  ok number :=0;
  nrDepar number:=0;
  nrDeparPutini number:=0;
  idNou number:=0;
begin
      select empno into ok
       from emp
       where mgr=idSef and rownum <2;
   
      select max(empno) into idNou
        from emp;
   open angajati;
   fetch angajati into nrDepar ;
   close angajati;
   open putini ;
   fetch putini into nrDeparPutini;
   close putini;
  if ok=0 then
      raise nuExista;
    elsif nrDepar=0 then
      insert into emp values(idNou+1,nume,slujba,idSef,null,salariu,null,nrDeparPutini);
    else insert into emp values(idNou+1,nume,slujba,idSef,null,salariu,null,nrDepar);
  end if;
    Exception when nuExista then
    DBMS_OUTPUT.PUT_LINE('Nu exista manager cu acest id');
    rollback;
end;

function verific(x emp.empno%type) 
                                  return number is 
  cursor angajati is
    select empno 
    from emp 
    where empno=x;
  ok number:=0;
begin
  open angajati;
  fetch angajati into ok;
  close angajati;
  if ok=0 then return 0;
    else return 1;
  end if;
end verific;

procedure concediaza (ida emp.empno%type)is
     nuExista exception;
     cursor angajati is
        select deptno from
              (select count(*)aa,deptno
                      from emp
                  where empno=ida
                  group by deptno order by aa)
              where rownum<2;
nrDeparDeSters number:=0;
nrDepar number:=0;
ok number;
begin
    open angajati;
    fetch angajati into nrDepar;
    close angajati;
    ok:=verific(ida);
    begin
    if ok=1 then
        select count(deptno) into nrDeparDeSters
              from emp 
              where NrDepar=deptno;
    DBMS_OUTPUT.PUT_LINE (nrDepar||' '||nrDeparDeSters);

        if nrDeparDeSters<2 then 
            delete from emp 
            where ida=empno;
             delete from dept
            where deptno=nrDepar;
 
         else 
             delete from emp 
             where ida=empno;
        end if;
   else raise nuExista;

      
  end if;
           exception when nuExista then
          DBMS_OUTPUT.PUT_LINE('Angajatul cu id '|| ida ||'nu exista');
       
    end;
end concediaza;

 function verific(x emp.ename%type) 
                                  return number is 
  cursor angajati is
      select empno 
      from emp 
      where ename=x;
  ok varchar2(20):=0;
begin
  open angajati;
  fetch angajati into ok;
  close angajati;
  if ok=0 then return 0;
    else return 1;
  end if;
end verific;

 procedure concediaza (ida emp.ename%type)is
     nuExista exception;
     cursor angajati is
        select deptno from
              (select count(*)aa,deptno
                      from emp
                  where ename=ida
                  group by deptno order by aa)
              where rownum<2;
nrDeparDeSters number:=0;
nrDepar number:=0;
ok number;
begin
    open angajati;
    fetch angajati into nrDepar;
    close angajati;
    ok:=verific(ida);
    begin
    if ok=1 then
        select count(deptno) into nrDeparDeSters
              from emp 
              where NrDepar=deptno;
    DBMS_OUTPUT.PUT_LINE (nrDepar||' '||nrDeparDeSters);

        if nrDeparDeSters<2 then 
            delete from emp 
            where ida=ename;
             delete from dept
            where deptno=nrDepar;
 
         else 
             delete from emp 
             where ida=ename;
        end if;
   else raise nuExista;

      
  end if;
           exception when nuExista then
          DBMS_OUTPUT.PUT_LINE('Angajatul '|| ida ||' nu exista');
       
    end;
end concediaza;

 procedure adaugaDep (nume dept.dname%type,lo dept.loc%type) is
  maxi number :=0;
begin
  select max(deptno)aa  into maxi
      from dept;
  insert into DEPT values(maxi+10,nume,lo);
end adaugaDep;

 procedure afiseaza(scrie emp.ename%type) is
cursor angajati is
    select * 
    from emp;
  out_File UTL_FILE.FILE_TYPE;

begin
  out_File := UTL_FILE.FOPEN('BAU', 'batotest.txt' , 'W');
  if scrie='ecran' then
      for i in angajati loop 
          DBMS_OUTPUT.PUT_LINE(i.empno ||' '|| i.ename ||' '|| i.job||' '|| i.mgr||' '|| i.hiredate ||' '|| i.sal||' '||i.comm||' '||i.deptno);
      end loop;
   elsif scrie='fisier' then 
      for i in angajati loop 
      UTL_FILE.PUT_LINE(out_file ,i.empno ||' '|| i.ename ||' '|| i.job||' '|| i.mgr||' '|| i.hiredate ||' '|| i.sal||' '||i.comm||' '||i.deptno);
      end loop;
   else
      DBMS_OUTPUT.PUT_LINE('Optiunde invalida');
 end if;
 UTL_FILE.FCLOSE(out_file);
 EXCEPTION
WHEN UTL_FILE.INVALID_FILEHANDLE THEN --7
RAISE_APPLICATION_ERROR(-20001,'Invalid File.');
WHEN UTL_FILE.WRITE_ERROR THEN --8
RAISE_APPLICATION_ERROR (-20002, 'Unable to
write to file');
 end afiseaza;
 
 end tema6;
/
declare
begin
tema6.afiseaza('ecran');
tema6.adaugaDep('WEB','SABAOANI');
tema6.adauga('Andrei',1003,'WEB-DEV',7839);
tema6.adauga('Vasile',900,'CLERK',7839);
tema6.afiseaza('ecran');
tema6.afiseaza('fisier');
tema6.concediaza('CLARK');
tema6.concediaza(7788);
TEMA6.AFISEAZA('ecran');
end;

  
  /

--grant execute on UTL_FILE to PUBLIC;
 
--GRANT EXECUTE ON SYS.UTL_FILE TO system;
