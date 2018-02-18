{shared{
  open Eliom_lib
  open Eliom_content
  open Html5.D
  open Eliom_parameter
}}

module Config =
  struct
    let port = 80 (* port access to the website *)
  end

module CharterBroker_app =
  Eliom_registration.App (
    struct
      let application_name = "CharterBroker"
    end)

let main_service =
  Eliom_service.App.service ~path:[] ~get_params:Eliom_parameter.unit ()

let available_leg_service =
  Eliom_service.App.service ~path:["available_leg"] ~get_params:Eliom_parameter.unit ()

(* Action to write the request for quote to the db and send an e-mail *)
let request_for_quote_action =
  Eliom_service.Http.post_coservice' ~post_params:(string "first_name" **
                                                   string "last_name **" **
                                                   string "phone_number" **
                                                   string "email" **
                                                   string "departure_city" **
                                                   string "arrival_city" **
                                                   string "departure_date" **
                                                   string "return_date" **
                                                   string "number_of_passengers"
                                                  ) ()

(* Action to write available legs to the db *)
let list_available_leg_action =
  Eliom_service.Http.post_coservice' ~post_params:(string "departure_city" **
                                                   string "arrival_city" **
                                                   int "departure_year" **
                                                   int "departure_month" **
                                                   int "departure_day" **
                                                   string "available_seats" **
                                                   string "aircraft_type"
                                                  ) ()

(* Bootstrap CDN link *)
let bootstrap_cdn_link =
    let cdn_link = "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" in
      link ~rel:[`Stylesheet] ~href:(Xml.uri_of_string cdn_link)
        ()

(* FontAwesome CDN link *)
let font_awesome_cdn_link =
    let cdn_link = "//netdna.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css" in
      link ~rel:[`Stylesheet] ~href:(Xml.uri_of_string cdn_link)
        ()

let request_for_quote_form =
  Eliom_content.Html5.F.post_form ~service:request_for_quote_action ~port:Config.port
  (
    fun (first_name,
         (last_name,
          (phone_number,
           (email,
            (departure_city,
             (arrival_city,
              (departure_date,
               (return_date,
                number_of_passengers)))))))) ->
      [div ~a:[a_id "rfq_form_outer_div"]
       [div ~a:[a_class ["panel panel-primary"]; a_id "rfq_panel"]
        [div ~a:[a_class ["panel-heading"]; a_id "rfq_heading"]
         [h3 ~a:[a_class ["panel-title"; "text-center"]; a_id "rfq_title"]
          [pcdata "Request a Quote"]
         ];

         (*div ~a:[a_class ["panel-body"]; a_style "border-radius: 10px; background: whitesmoke"]*)
         div ~a:[a_class ["panel-body"]; a_style "border-radius: 10px; background: transparent"]
         [

          div ~a:[a_class ["form-group"]]
          [div ~a:[a_class ["input-group"]]
           [Raw.span ~a:[a_class ["input-group-addon"]]
            [Raw.span ~a:[a_class ["glyphicon glyphicon-user"]] []
            ];
            string_input ~a:[a_class ["form-control"]; a_placeholder "First Name"]
              ~input_type:`Text ~name:first_name ()
           ]
          ];

          div ~a:[a_class ["form-group"]]
          [div ~a:[a_class ["input-group"]]
           [Raw.span ~a:[a_class ["input-group-addon"]]
            [Raw.span ~a:[a_class ["glyphicon glyphicon-user"]] []
            ];
            string_input ~a:[a_class ["form-control"]; a_placeholder "Last Name"]
              ~input_type:`Text ~name:last_name ()
           ]
          ];

          div ~a:[a_class ["form-group"]]
          [div ~a:[a_class ["input-group"]]
           [Raw.span ~a:[a_class ["input-group-addon"]]
            [Raw.span ~a:[a_class ["glyphicon glyphicon-earphone"]] []
            ];
            string_input ~a:[a_class ["form-control"]; a_placeholder "Phone Number"]
              ~input_type:`Text ~name:phone_number ()
           ]
          ];

          div ~a:[a_class ["form-group"]]
          [div ~a:[a_class ["input-group"]]
           [Raw.span ~a:[a_class ["input-group-addon"]]
            [Raw.span ~a:[a_class ["glyphicon glyphicon-envelope"]] []
            ];
            string_input ~a:[a_class ["form-control"]; a_placeholder "Email Address"]
              ~input_type:`Text ~name:email ()
           ]
          ];

          div ~a:[a_class ["form-group"]]
          [div ~a:[a_class ["input-group"]]
           [Raw.span ~a:[a_class ["input-group-addon"]]
            [Raw.span ~a:[a_class ["glyphicon glyphicon-export"]] []
            ];
            string_input ~a:[a_class ["form-control"]; a_placeholder "Departure City"]
              ~input_type:`Text ~name:departure_city ()
           ]
          ];

          div ~a:[a_class ["form-group"]]
          [div ~a:[a_class ["input-group"]]
           [Raw.span ~a:[a_class ["input-group-addon"]]
            [Raw.span ~a:[a_class ["glyphicon glyphicon-import"]] []
            ];
            string_input ~a:[a_class ["form-control"]; a_placeholder "Arrival City"]
              ~input_type:`Text ~name:arrival_city ()
           ]
          ];

          div ~a:[a_class ["form-group"]]
          [div ~a:[a_class ["input-group"]]
           [Raw.span ~a:[a_class ["input-group-addon"]]
            [Raw.span ~a:[a_class ["glyphicon glyphicon-calendar"]] []
            ];
            string_input ~a:[a_class ["form-control"]; a_placeholder "Departure Date"]
              ~input_type:`Text ~name:departure_date ()
           ]
          ];

          div ~a:[a_class ["form-group"]]
          [div ~a:[a_class ["input-group"]]
           [Raw.span ~a:[a_class ["input-group-addon"]]
            [Raw.span ~a:[a_class ["glyphicon glyphicon-calendar"]] []
            ];
            string_input ~a:[a_class ["form-control"]; a_placeholder "Return Date"]
              ~input_type:`Text ~name:return_date ()
           ]
          ];

          div ~a:[a_class ["form-group"]]
          [div ~a:[a_class ["input-group"]]
           [Raw.span ~a:[a_class ["input-group-addon"]]
            [Raw.span ~a:[a_class ["glyphicon glyphicon-plus"]] []
            ];
            string_input ~a:[a_class ["form-control"]; a_placeholder "Passengers"]
              ~input_type:`Text ~name:number_of_passengers ()
           ]
          ];

         div ~a:[a_id "rfq_button_div"]
         [button ~a:[a_class ["btn btn-lg btn-success btn-block"];
                     a_id "rfq_submit_button"]
                 ~button_type:`Submit [pcdata "Submit"]
         ]
        ]
       ]
      ]
     ]
  )

let list_available_leg_form =
  Eliom_content.Html5.F.post_form ~service:list_available_leg_action ~port:Config.port
  (
    fun (departure_city,
         (arrival_city,
          (departure_year,
           (departure_month,
            (departure_day,
             (available_seats,
              aircraft_type)))))) ->
      [div ~a:[a_id "rfq_form_outer_div"]
       [div ~a:[a_class ["panel panel-primary"]; a_id "rfq_panel"]
        [div ~a:[a_class ["panel-heading"]; a_id "rfq_heading"]
         [h3 ~a:[a_class ["panel-title"; "text-center"]; a_id "rfq_title"]
          [pcdata "List an Available Leg"]
         ];

         div ~a:[a_class ["panel-body"]; a_style "border-radius: 10px; background: transparent"]
         [

          div ~a:[a_class ["form-group"]]
          [div ~a:[a_class ["input-group"]]
           [Raw.span ~a:[a_class ["input-group-addon"]]
            [Raw.span ~a:[a_class ["glyphicon glyphicon-export"]] []
            ];
            string_input ~a:[a_class ["form-control"]; a_placeholder "Departure City"]
              ~input_type:`Text ~name:departure_city ()
           ]
          ];

          div ~a:[a_class ["form-group"]]
          [div ~a:[a_class ["input-group"]]
           [Raw.span ~a:[a_class ["input-group-addon"]]
            [Raw.span ~a:[a_class ["glyphicon glyphicon-import"]] []
            ];
            string_input ~a:[a_class ["form-control"]; a_placeholder "Arrival City"]
              ~input_type:`Text ~name:arrival_city ()
           ]
          ];

          div ~a:[a_class ["form-group"]]
          [div ~a:[a_class ["input-group"]]
           [Raw.span ~a:[a_class ["input-group-addon"]]
            [Raw.span ~a:[a_class ["glyphicon glyphicon-calendar"]] []
            ];
            int_input ~a:[a_class ["form-control"]; a_placeholder "Departure Year"]
              ~input_type:`Text ~name:departure_year ()
           ]
          ];

          div ~a:[a_class ["form-group"]]
          [div ~a:[a_class ["input-group"]]
           [Raw.span ~a:[a_class ["input-group-addon"]]
            [Raw.span ~a:[a_class ["glyphicon glyphicon-calendar"]] []
            ];
            int_input ~a:[a_class ["form-control"]; a_placeholder "Departure Month"]
              ~input_type:`Text ~name:departure_month ()
           ]
          ];

          div ~a:[a_class ["form-group"]]
          [div ~a:[a_class ["input-group"]]
           [Raw.span ~a:[a_class ["input-group-addon"]]
            [Raw.span ~a:[a_class ["glyphicon glyphicon-calendar"]] []
            ];
            int_input ~a:[a_class ["form-control"]; a_placeholder "Departure Day"]
              ~input_type:`Text ~name:departure_day ()
           ]
          ];

          div ~a:[a_class ["form-group"]]
          [div ~a:[a_class ["input-group"]]
           [Raw.span ~a:[a_class ["input-group-addon"]]
            [Raw.span ~a:[a_class ["glyphicon glyphicon-plus"]] []
            ];
            string_input ~a:[a_class ["form-control"]; a_placeholder "Available Seats"]
              ~input_type:`Text ~name:available_seats ()
           ]
          ];

          div ~a:[a_class ["form-group"]]
          [div ~a:[a_class ["input-group"]]
           [Raw.span ~a:[a_class ["input-group-addon"]]
            [Raw.span ~a:[a_class ["glyphicon glyphicon-plus"]] []
            ];
            string_input ~a:[a_class ["form-control"]; a_placeholder "Aircraft Type"]
              ~input_type:`Text ~name:aircraft_type ()
           ]
          ];

         div ~a:[a_id "rfq_button_div"]
         [button ~a:[a_class ["btn btn-lg btn-success btn-block"];
                     a_id "rfq_submit_button"]
                 ~button_type:`Submit [pcdata "Submit"]
         ]
        ]
       ]
      ]
     ]
  )

(* TODO: Add cost per seat, better to fill a few seats than none *)
let available_legs_table () =
  let open Db_funs in
  lwt legs = available_legs () in
  let tr_of_leg leg =
    tr [
      td ~a:[a_id "legs_tbl_td"] [pcdata leg.departure_city];
      td ~a:[a_id "legs_tbl_td"] [pcdata leg.arrival_city];
      td ~a:[a_id "legs_tbl_td"] [pcdata (string_of_date leg.departure_date)];
      td ~a:[a_id "legs_tbl_td"] [pcdata (string_of_int leg.available_seats)];
      td ~a:[a_id "legs_tbl_td"] [pcdata leg.aircraft_type]
    ]
  in
  let t_head =
    thead
     [tr
      [th ~a:[a_id "legs_tbl_header"] [pcdata "Departure City"];
       th ~a:[a_id "legs_tbl_header"] [pcdata "Arrival City"];
       th ~a:[a_id "legs_tbl_header"] [pcdata "Departure Date"];
       th ~a:[a_id "legs_tbl_header"] [pcdata "Available Seats"];
       th ~a:[a_id "legs_tbl_header"] [pcdata "Aircraft Type"]
      ]
     ]
  in
  let tbl_rows = List.map (tr_of_leg) legs in
  Lwt.return @@ table ~a:[a_class ["table table-striped"]] ~thead:t_head tbl_rows

let () =
  CharterBroker_app.register
    ~service:main_service
    (fun () () ->
      lwt avail_legs_tbl = available_legs_table () in
      Lwt.return
        (Eliom_tools.F.html
           ~title:"Private Air Charters"
           ~css:[["css";"CharterBroker.css"]]
           ~other_head:[bootstrap_cdn_link; font_awesome_cdn_link]
           Html5.F.(body [
             div ~a:[a_id "main_header"] [pcdata "U.S. Charter Brokers"];
             div ~a:[a_id "main_header_contact"]
             [div ~a:[a_id "email_contact"] [pcdata "Email: john@uscharterbrokers.com"];
              div ~a:[a_id "phone_contact"] [pcdata "Phone: (806) 680-5212"];
             ];
             div ~a:[a_id "main_pg_outer_div"]
             [div ~a:[a_id "form_div"] [request_for_quote_form ()];
              div ~a:[a_id "info_div"]
              [
                div ~a:[a_id "main_pg_bullets"]
                [div ~a:[a_class ["glyphicon glyphicon-menu-right"]; a_id "glyphs"] [];
                 h3 ~a:[a_id "bullet_text"]
                   [pcdata ("The premier solution for all your private charter needs.")]
                ];

                div ~a:[a_id "main_pg_bullets"]
                [div ~a:[a_class ["glyphicon glyphicon-menu-right"]; a_id "glyphs"] [];
                 h3 ~a:[a_id "bullet_text"]
                   [pcdata ("24/7 Support for vacation, business, and " ^
                            "ASAP/emergency travel bookings.")]
                ];

                div ~a:[a_id "main_pg_bullets"]
                [div ~a:[a_class ["glyphicon glyphicon-menu-right"]; a_id "glyphs"] [];
                 h3 ~a:[a_id "bullet_text"]
                   [pcdata "Access to domestic and international charter services."]
                ];

                div ~a:[a_id "main_pg_bullets"]
                [div ~a:[a_class ["glyphicon glyphicon-menu-right"]; a_id "glyphs"] [];
                 h3 ~a:[a_id "bullet_text"]
                   [pcdata ("U.S. Charter Brokers provides the highest quality charters, " ^
                          "while maintaining the best value for its clients.")]
                ];

                div ~a:[a_id "main_pg_bullets"]
                [div ~a:[a_class ["glyphicon glyphicon-menu-right"]; a_id "glyphs"] [];
                 h3 ~a:[a_id "bullet_text"]
                   [pcdata "Request a free no-obligation quote for your trip today."]
                ]

              ];
              div ~a:[a_id "available_legs_title"] [h1 [pcdata "Available Empty Legs"]];
              div ~a:[a_id "available_legs_info"]
              [h4
               [pcdata ("Empty leg flights are often discounted. " ^
                        "Contact us by phone or email about any of the flights listed below.")
               ]
              ];
              div ~a:[a_id "available_legs_table"] [avail_legs_tbl]
             ]
            ]
           )))

let () =
  CharterBroker_app.register
    ~service:available_leg_service
    (fun () () ->
      Lwt.return
        (Eliom_tools.F.html
           ~title:"List available legs"
           ~css:[["css";"CharterBroker.css"]]
           ~other_head:[bootstrap_cdn_link; font_awesome_cdn_link]
           Html5.F.(body [
             div ~a:[a_id "main_header"] [pcdata "U.S. Charter Brokers"];
             div ~a:[a_id "main_pg_outer_div"]
             [div ~a:[a_id "available_leg_form_div"] [list_available_leg_form ()];
             ]
            ]
           )))

{client{

  open Dom_html

  let form_submit_test () = window##alert (Js.string "Request for Quote submitted!")

}}

(* Write the new Request for Quote to the database & send an e-mail *)
let () =
  Eliom_registration.Action.register
  ~options:`Reload
  ~service:request_for_quote_action
  (fun () (first_name,
           (last_name,
            (phone_number,
             (email,
              (departure_city,
               (arrival_city,
                (departure_date,
                 (return_date,
                 num_passengers)))))))) ->
    let _ = {unit{form_submit_test ()}} in
    let open Db_funs in
    lwt write_result =
      Db_funs.write_request_for_quote
        ~first_name
        ~last_name
        ~phone_number
        ~email
        ~departure_city
        ~arrival_city
        ~departure_date
        ~return_date
        ~num_passengers
    in
    match write_result with
    | DbWriteFail msg -> Lwt.return @@ ignore {unit{window##alert(Js.string %msg)}}
    | DbWriteSuccess ->
      let subject = "\"RFQ " ^ first_name ^ " " ^ last_name ^ "\" " in
      let msg =
        "\"First Name: " ^ first_name ^ "\n\n" ^
        "Last Name: " ^ last_name ^ "\n\n" ^
        "Phone Number: " ^ phone_number ^ "\n\n" ^
        "e-mail: " ^ email ^ "\n\n" ^
        "Departure City: " ^ departure_city ^ "\n\n" ^
        "Arrival City: " ^ arrival_city ^ "\n\n" ^
        "Departure Date: " ^ departure_date ^ "\n\n" ^
        "Return Date: " ^ return_date ^ "\n\n" ^
        "Number of Passengers: " ^ num_passengers ^ "\""
      in
      lwt () =
        try
          let s = "python send_mail.py 'johnmbrittain@gmail.com' " ^ subject ^ msg in
          Lwt_io.print s >>
          lwt mail_process_status = Lwt_process.exec (Lwt_process.shell s) in
          Lwt_io.print "Mail should have worked!"
        with _ -> Lwt_io.print "Error: send_mail.py did not work"
      in
      Lwt.return ()
  )

(* Write the available leg to the database *)
let () =
  Eliom_registration.Action.register
  ~options:`Reload
  ~service:list_available_leg_action
  (fun () (departure_city,
           (arrival_city,
            (departure_year,
             (departure_month,
              (departure_day,
               (available_seats,
                aircraft_type)))))) ->
    let open Db_funs in
    (*lwt write_result = *)
      write_available_leg
        ~departure_city
        ~arrival_city
        ~departure_year
        ~departure_month
        ~departure_day
        ~available_seats
        ~aircraft_type
    >>= fun db_write_result -> Lwt.return_unit
    (*
    Lwt_io.print "\nWriting the data to the database:" >>
    Lwt_io.print ("\ndeparture_city: " ^ departure_city) >>
    Lwt_io.print ("\narrival_city: " ^ arrival_city) >>
    Lwt_io.print ("\ndeparture_date: " ^ departure_year) >>
    Lwt_io.print ("\navailable_seats: " ^ available_seats) >>
    Lwt_io.print ("\naircraft_type: " ^ aircraft_type)*)
  )
