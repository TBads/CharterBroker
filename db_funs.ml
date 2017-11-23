(* MySql database functions *)

open Mysql

let (>>=) = Lwt.bind

(* Database *)
let user_db = {
  dbhost   = None;
  dbname   = Some "muz";
  dbport   = Some 3306;
  dbpwd    = Some "HPMpRjbvWMe49A95xHsFhRyw";
  dbuser   = Some "btc_admin_4A3f8E";
  dbsocket = None
}

(* Write a new Request for Quote to the database *)
let write_request_for_quote
  ~first_name
  ~last_name
  ~phone_number
  ~email
  ~departure_city
  ~arrival_city
  ~departure_date
  ~number_of_passengers =
  let conn = connect user_db in
  let esc s = Mysql.real_escape conn s in
  let sql_stmt =
    "INSERT INTO CharterBroker.RequestForQuote (" ^
    "first_name, last_name, phone_number, email_address, departure_city, " ^
    "arrival_city, departure_date, passengers)" ^
    " VALUES ('" ^
    (esc first_name) ^ "', '" ^
    (esc last_name) ^ "', '" ^
    (esc phone_number) ^ "', '" ^
    (esc email) ^ "', '" ^
    (esc departure_city) ^ "', '" ^
    (esc arrival_city) ^ "', '" ^
    (esc departure_date) ^ "', '" ^
    (esc number_of_passengers) ^ "')"
  in
  let _ = exec conn sql_stmt in
  Lwt.return @@ disconnect conn
