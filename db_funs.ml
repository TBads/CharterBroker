(* MySql database functions *)

open Mysql
open Lwt.Infix
open Secure_info

let (>>=) = Lwt.bind

type check = Success | CheckFailure of string

type db_write_result = DbWriteSuccess | DbWriteFail of string

let len_check
  ~first_name
  ~last_name
  ~phone_number
  ~email
  ~departure_city
  ~arrival_city
  ~departure_date
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
  ~num_passengers =
  (* First check that all user inputs meet the length requirements *)
  match len_check ~first_name ~last_name ~phone_number ~email ~departure_city
          ~arrival_city ~departure_date ~num_passengers with
  | CheckFailure msg -> Lwt.return @@ DbWriteFail msg
  | Success ->
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
      (esc num_passengers) ^ "')"
    in
    let _ = exec conn sql_stmt in
    let () = disconnect conn in
    Lwt.return DbWriteSuccess
