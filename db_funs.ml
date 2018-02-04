(* MySql database functions *)

open Mysql
open Lwt.Infix
open Secure_info

let (>>=) = Lwt.bind

type check = Success | CheckFailure of string

type db_write_result = DbWriteSuccess | DbWriteFail of string

type date = {
  year : int;
  month : int;
  day : int;
}

type available_leg = {
  leg_number : int;
  departure_city : string;
  arrival_city : string;
  departure_date : date;
  available_seats : int;
  aircraft_type : string
}

let string_of_month m =
match m with
| 1 -> "January"
| 2 -> "February"
| 3 -> "March"
| 4 -> "April"
| 5 -> "May"
| 6 -> "June"
| 7 -> "July"
| 8 -> "August"
| 9 -> "September"
| 10 -> "October"
| 11 -> "November"
| 12 -> "December"
| _ -> failwith ("ERROR: invalid month " ^ string_of_int m  ^ " passed into string_of_month.")

let string_of_date d =
  string_of_int d.day ^ "-" ^
  string_of_month d.month ^ "-" ^
  string_of_int d.year

let string_of_option so =
  match so with
  | Some s -> s
  | None -> ""

let sll_of_res res =
  Mysql.map res (fun a -> Array.to_list a)
  |> List.map (List.map string_of_option)

let available_leg_of_results sl = {
  leg_number      = int_of_string @@ List.nth sl 0;
  departure_city  = List.nth sl 1;
  arrival_city    = List.nth sl 2;
  departure_date  = {
    year = int_of_string @@ List.nth sl 3;
    month = int_of_string @@ List.nth sl 4;
    day = int_of_string @@ List.nth sl 5
  };
  available_seats = (try int_of_string @@ List.nth sl 6 with _ -> -1);
  aircraft_type   = List.nth sl 7
}

let len_check
  ~first_name
  ~last_name
  ~phone_number
  ~email
  ~departure_city
  ~arrival_city
  ~departure_date
  ~return_date
  ~num_passengers =
  let open String in
  let failed_fields = ref [] in
  let () =
    match length first_name <= 45 with
    | true -> ()
    | false -> failed_fields := !failed_fields @ ["First Name"]
  in
  let () =
    match length last_name <= 45 with
    | true -> ()
    | false -> failed_fields := !failed_fields @ ["Last Name"]
  in
  let () =
    match length phone_number <= 45 with
    | true -> ()
    | false -> failed_fields := !failed_fields @ ["Phone Number"]
  in
  let () =
    match length email <= 45 with
    | true -> ()
    | false -> failed_fields := !failed_fields @ ["Email Address"]
  in
  let () =
    match length departure_city <= 45 with
    | true -> ()
    | false -> failed_fields := !failed_fields @ ["Departure City"]
  in
  let () =
    match length arrival_city <= 45 with
    | true -> ()
    | false -> failed_fields := !failed_fields @ ["Arrival City"]
  in
  let () =
    match length departure_date <= 45 with
    | true -> ()
    | false -> failed_fields := !failed_fields @ ["Departure Date"]
  in
  let () =
    match length return_date <= 45 with
    | true -> ()
    | false -> failed_fields := !failed_fields @ ["Return Date"]
  in
  let () =
    match length num_passengers <= 45 with
    | true -> ()
    | false -> failed_fields := !failed_fields @ ["Number of Passengers"]
  in
  match !failed_fields with
  | [] -> Success
  | _ -> (
      let err_fields =
        if List.length !failed_fields == 1
        then "\n" ^ (List.hd !failed_fields)
        else (
          if List.length !failed_fields == 2
          then "\n" ^ (String.concat "\n" !failed_fields)
          else (
            let first_words = List.rev @@ List.tl @@ List.rev !failed_fields in
            let last_word = List.hd @@ List.rev !failed_fields in
            "\n" ^ (String.concat "\n" first_words) ^ "\n" ^ last_word
          )
        )
      in
      CheckFailure ("Error: Each field is limited to 45 characters, " ^
                    "please use less than 45 characters for: " ^ err_fields)
    )

(* Write a new Request for Quote to the database *)
let write_request_for_quote
  ~first_name
  ~last_name
  ~phone_number
  ~email
  ~departure_city
  ~arrival_city
  ~departure_date
  ~return_date
  ~num_passengers =
  (* First check that all user inputs meet the length requirements *)
  match len_check ~first_name ~last_name ~phone_number ~email ~departure_city
          ~arrival_city ~departure_date ~return_date ~num_passengers with
  | CheckFailure msg -> Lwt.return @@ DbWriteFail msg
  | Success ->
    let conn = connect user_db in
    let esc s = Mysql.real_escape conn s in
    let sql_stmt =
      "INSERT INTO CharterBroker.RequestForQuote (" ^
      "first_name, last_name, phone_number, email_address, departure_city, " ^
      "arrival_city, departure_date, return_date, passengers)" ^
      " VALUES ('" ^
      (esc first_name) ^ "', '" ^
      (esc last_name) ^ "', '" ^
      (esc phone_number) ^ "', '" ^
      (esc email) ^ "', '" ^
      (esc departure_city) ^ "', '" ^
      (esc arrival_city) ^ "', '" ^
      (esc departure_date) ^ "', '" ^
      (esc return_date) ^ "', '" ^
      (esc num_passengers) ^ "')"
    in
    let _ = exec conn sql_stmt in
    let () = disconnect conn in
    Lwt.return DbWriteSuccess

(* Write a new available leg to the database *)
let write_available_leg
  ~departure_city
  ~arrival_city
  ~departure_year
  ~departure_month
  ~departure_day
  ~available_seats
  ~aircraft_type =
  let conn = connect user_db in
    let esc s = Mysql.real_escape conn s in
    let sql_stmt =
      "INSERT INTO CharterBroker.AvailableLegs " ^
      "(departure_city, arrival_city, departure_year, departure_month, departure_day, " ^
      "available_seats, aircraft_type) VALUES ('" ^
      (esc departure_city) ^ "', '" ^
      (esc arrival_city) ^ "', " ^
      (esc @@ string_of_int departure_year) ^ ", " ^
      (esc @@ string_of_int departure_month) ^ ", " ^
      (esc @@ string_of_int departure_day) ^ ", " ^
      (esc available_seats) ^ ", '" ^
      (esc aircraft_type) ^ "')"
    in
    (*Lwt_io.print sql_stmt >>*)
    let _ = exec conn sql_stmt in
    let () = disconnect conn in
    Lwt.return DbWriteSuccess

(* Get the available legs from the database *)
let available_legs () =
  let open Unix in
  let now = Unix.gmtime @@ Unix.time () in
  let y, m, d = 1900 + now.tm_year, now.tm_mon, now.tm_mday in
  let conn = Mysql.connect user_db in
  let sql_stmt = "SELECT * FROM CharterBroker.AvailableLegs" in
  let res = exec conn sql_stmt |> sll_of_res in
  disconnect conn;
  let available_legs =
    (List.map (available_leg_of_results) res)
    |> List.filter (fun x ->
      x.departure_date.year >= y &&
      x.departure_date.month >= m &&
      x.departure_date.day >= d
    )
  in
  Lwt.return available_legs
