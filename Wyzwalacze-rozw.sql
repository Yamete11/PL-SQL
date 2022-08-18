
set serveroutput on;
--Wyzwalacz nie pozwala obnizac pensje pracownikom i dodawac nowych pracownikow z pensja nizej minimalniej
create or replace trigger trig_os
before insert or update on pracownik
for each row
declare
v_minpensja pracownik.pensja%type;
v_pensja pracownik.pensja%type;
v_avgpensja pracownik.pensja%type;

begin
    if updating then
        if :old.pensja > :new.pensja then
            raise_application_error(-20100, 'Nie mozna obnizac pensji');
        end if;
    elsif inserting then
        select min(p.pensja) into v_minpensja from pracownik p;
        if :new.pensja < v_minpensja then
            raise_application_error(-20100, 'Nie mozna wprawadzac nowych pracownikow z mniejsza pensja');
        end if;
    end if;

end;

select * from pracownik;

alter trigger trig_os disable;
alter trigger trig_os enable;

select min(p.pensja) from pracownik p;

insert into pracownik values(6, 2, 500);

update pracownik set pensja = 900 where id_osoba_pracownik = 3;




create or replace procedure increaseSalary (incre number(22)) is
cursor cur is select p.id_osoba_pracownik, p.pensja from pracownik p;
v_osoba pracownik.id_osoba_pracownik%type;
v_pensja pracownik.pensja%type;
v_avgpensja pracownik.pensja%type;
begin
    open cur;
    loop
        fetch cur into v_osoba, v_pensja;
        exit when cur%notfound;
        if incre < 1.0 then
            select min(pensja) into v_avgpensja from pracownik;
            
            if incre * v_pensja < v_avgpensja then
                dbms_output.put_line('Nowe pensja nie moze byc nizej sredniej');
            else
                update pracownik 
                set pensja = pensja * incre
                where id_osoba_pracownik = v_osoba;
                dbms_output.put_line('Pensja pracownika zostala podwyzszona do ' || v_pensja * incre);
            end if;
        else 
            update pracownik 
            set pensja = pensja * incre
            where id_osoba_pracownik = v_osoba;
            dbms_output.put_line('Pensja pracownika zostala podwyzszona do ' || v_pensja * incre);
        end if;
    end loop;
close cur;
end increaseSalary;


select * from pracownik;
select avg(pensja) from pracownik;

execute increaseSalary(1.1);

