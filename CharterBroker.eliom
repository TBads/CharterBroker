{shared{
  open Eliom_lib
  open Eliom_content
  open Html5.D
  open Eliom_parameter
}}

module CharterBroker_app =
  Eliom_registration.App (
    struct
      let application_name = "CharterBroker"
    end)

let main_service =
  Eliom_service.Http.service ~path:[] ~get_params:Eliom_parameter.unit ()

let available_leg_service =
  Eliom_service.Http.service ~path:["available_leg"] ~get_params:Eliom_parameter.unit ()

let faq_service =
  Eliom_service.App.service ~path:["faq"] ~get_params:Eliom_parameter.unit ()

let privacy_policy_service =
  Eliom_service.App.service ~path:["privacy_policy"] ~get_params:Eliom_parameter.unit ()

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
  Eliom_service.Http.post_service
    ~fallback:main_service
    ~post_params:(string "departure_city" **
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
    let cdn_link = "https://netdna.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css" in
      link ~rel:[`Stylesheet] ~href:(Xml.uri_of_string cdn_link)
        ()

let avinode_js =
  let url = "https://apps.avinode.com/webapp/rest/bootstrap?Avinode-WEB-APP=eyJraWQiOiIxNkVBQkQ5RS1BRjYyLTQ4NTEtODk5Qi1BM0UwMThGRjYxNDciLCJ0eXAiOiJKV1QiLCJhbGciOiJSUzUxMiJ9.eyJzdWIiOiJmMGZmZjYxMC05YWU5LTQyNTEtYTMyOC1jMzc4ZmIyNzJkNzQiLCJhdmlkb21haW4iOiIuYXZpbm9kZS5jb20iLCJhdml0ZW5hbnQiOjExMzU3LCJpc3MiOiJhdmlub2RlIiwiYXZpdHlwZSI6MTAsImF2aW5vbmNlIjoiMGI1NGExMDctNTA1My00ZDg1LTg4M2QtZTQzYzYxNmY2OGRhIn0.a1RxbQFm1AEzEbk0iQb_ifTAkSLZtA2XZMVro34TF06EowitV_NsVEhiswp6LYTQSZW-ovpeBdv9dM6ppyj9tGPhC1nLwHbN_G6PhnGfYYxXIOnJb3VdZFFz23rNq6xTrG7OMZUVYIi419mntgc03z6vG9RGYcJbaxAmkJxgToJO2O68-EQOGmw-CCdAcCDQkGaCHJbuXVHGw-Ra7bJfvr0aeB-8QbXKQuZ3dINiqU5xLhNWbOsxrhviu7D_1cgyo4j5KifVu_stMkRpsAA_kt-VP_utIqNMa6CfvYdt4F_RSA4IBYGKJpZr0eXHTnmv8xQ_nQaRqL9db-2lGedylw"
  in
  js_script ~uri:(Xml.uri_of_string url) ()

let localhost_css_header =
  let css_addr = make_uri (Eliom_service.static_dir ()) ["css"; "CharterBroker.css"] in
  link ~rel:[`Stylesheet] ~href:css_addr
  ()

let secure_css_header =
  let css_addr = "https://uscharterbrokers.com/css/CharterBroker.css" in
    link ~rel:[`Stylesheet] ~href:(Xml.uri_of_string css_addr)
    ()

let secure_js_link =
  let js_addr = "https://uscharterbrokers.com/CharterBroker.js" in
  let uri = Xml.uri_of_string js_addr in
  js_script ~uri:uri ()

let other_head =
  let open Config in
  match env with
  | Dev -> [
    bootstrap_cdn_link;
    font_awesome_cdn_link;
    avinode_js;
    localhost_css_header;
    (* TODO: viewport tag*)
  ]
  | Prod -> [
    bootstrap_cdn_link;
    font_awesome_cdn_link;
    avinode_js;
    secure_js_link;
    secure_css_header;
    (* TODO: viewport tag*)
  ]

let request_for_quote_form =
  Eliom_content.Html5.F.post_form ~service:request_for_quote_action
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
  Eliom_content.Html5.F.post_form ~service:list_available_leg_action
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
    tr ~a:[a_style "background-color: transparent"] [
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


let main_header = [
  div ~a:[a_id "main_header"] [pcdata "U.S. Charter Brokers"];
    div ~a:[a_id "main_header_contact"]
    [
      div ~a:[a_id "home_link_div"]
      [a ~a:[a_class ["home_link"]] ~service:main_service
        [pcdata "Home"]
        ()
      ];

      div ~a:[a_id "email_contact"]
      [Raw.a ~a:[a_href (Raw.uri_of_string "mailto:john@uscharterbrokers.com")]
        [pcdata "Email: john@uscharterbrokers.com"]
      ];

      div ~a:[a_id "phone_contact"]
      [Raw.a ~a:[a_href (Raw.uri_of_string "tel:18322805387")]
        [pcdata "Phone: (832) 280-JETS (5387)"]
      ];

      div ~a:[a_id "faq_link_div"]
      [a ~a:[a_class ["faq_link"]] ~service:faq_service
        [pcdata "FAQ"]
        ()
      ];

    ];
  ]

let () =
  Eliom_registration.Html5.register
    ~service:main_service
    (fun () () ->
      lwt avail_legs_tbl = available_legs_table () in
      Lwt.return
        (Eliom_tools.F.html
           ~title:"Private Air Charters"
           ~other_head:other_head
           Html5.F.(body (

            main_header @
            [
             div ~a:[a_id "main_pg_outer_div"]
             [
              div ~a:[a_id "avinodeApp"] [];
              avinode_js;
              (*div ~a:[a_id "form_div"] [request_for_quote_form ()];*)
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
               [pcdata ("Contact us by phone or email about any of the flights listed below.")
               ]
              ];
              div ~a:[a_id "available_legs_table"] [avail_legs_tbl];
              div ~a:[a_id "llc_footer"] [pcdata "U.S. Charter Brokers LLC"];
              div ~a:[a_id "privacy_footer"] [a privacy_policy_service [pcdata "Privacy Policy"] ()];
              div ~a:[a_id "disclaimer"] [pcdata "U.S. Charter Brokers LLC is an air charter broker, serving as an agent. U.S. Charter Brokers LLC does not own or operate any aircraft. All aircraft are operated by licensed and federally regulated Part 135 air charter operators."]
             ]
            ]
           ))))


let () =
  CharterBroker_app.register
    ~service:faq_service
    (fun () () ->
      Lwt.return
        (Eliom_tools.F.html
           ~title:"FAQ"
           ~css:[["css";"CharterBroker.css"]]
           ~other_head:other_head
           Html5.F.(body (
           main_header @
            [
             div ~a:[a_id "main_pg_outer_div"]
             [
              div ~a:[a_id "info_div"]
              [
               h2 ~a:[a_id "faq_text"]
               [pcdata "Why Choose U.S. Charter Brokers?"];

               h3 ~a:[a_id "faq_text"]
               [pcdata "As air charter brokers, we have several advantages."];

               h3 ~a:[a_id "faq_text"]
               [pcdata "-We represent the buying power of our entire clientele instead of just one person, giving an advantage when negotiating the best price for our clients."];

               h3 ~a:[a_id "faq_text"]
               [pcdata "-We have access to empty leg flights across the country to help find great pricing for you."];

               h3 ~a:[a_id "faq_text"]
               [pcdata "-We give you access to nearly every type of aircraft, instead of being limited to the few aircraft in your local charter operator’s fleet."];

               h3 ~a:[a_id "faq_text"]
               [pcdata "-We do not force you to sign a membership contract."];

               h2 ~a:[a_id "faq_text"]
               [pcdata "What Is An Air Charter Broker?"];

               h3 ~a:[a_id "faq_text"]
               [pcdata "An Air Charter Broker works directly with a client to find the right aircraft for your custom-tailored trip. We have access to thousands of charter aircraft operated by the best aircraft charter operators across the globe and we work directly with those operators to negotiate the best price on your behalf, taking the stress and work out of finding your aircraft."];

               h3 ~a:[a_id "faq_text"]
               [pcdata "We only work with reputable charter operators, and often have great, long-standing business relationships with many charter operators, helping get you from point A to B as safely, quickly, and smoothly as possible."];

               h2 ~a:[a_id "faq_text"]
               [pcdata "Advantages Of Using Brokers Vs Direct Charter or Membership"];

               h3 ~a:[a_id "faq_text"]
               [pcdata "Aircraft Advantages:"];

               h3 ~a:[a_id "faq_text"]
               [pcdata "-You are not limited to the aircraft that your local charter/membership service operates. You can select from a TurboProp for a quick weekend out to your ranch or favorite skiing destination, all the way up to Gulstream G650, Falcon 7X, Global, and other aircraft that can take you wherever you choose in the world."];

               h3 ~a:[a_id "faq_text"]
               [pcdata  "Financial Advantages:"];

               h3 ~a:[a_id "faq_text"]
               [pcdata "-You pay on a per-flight basis, no upfront 25/50/100 hour commitment"];

               h3 ~a:[a_id "faq_text"]
               [pcdata "-No inflated hourly costs that can be associated with other membership services"];

               h3 ~a:[a_id "faq_text"]
               [pcdata "-No membership contract"];

               h3 ~a:[a_id "faq_text"]
               [pcdata "-No initial membership fee"];

               h3 ~a:[a_id "faq_text"]
               [pcdata "-No monthly/annual dues"];

               h3 ~a:[a_id "faq_text"]
               [pcdata "Feel free to call and compare our pricing to your current membership rates."];

              div ~a:[a_id "llc_footer"] [pcdata "U.S. Charter Brokers LLC"];
              div ~a:[a_id "disclaimer"] [pcdata "U.S. Charter Brokers LLC is an air charter broker, serving as an agent. U.S. Charter Brokers LLC does not own or operate any aircraft. All aircraft are operated by licensed and federally regulated Part 135 air charter operators."]
             ]

            ]
           ]

           ))))

let () =
  CharterBroker_app.register
    ~service:privacy_policy_service
    (fun () () ->
      Lwt.return
        (Eliom_tools.F.html
           ~title:"Privacy Policy"
           ~css:[["css";"CharterBroker.css"]]
           ~other_head:other_head
           Html5.F.(body (
            main_header @
            [
             div ~a:[a_id "main_pg_outer_div"]
             [
              div ~a:[a_id "info_div"]
              [

                h2 ~a:[a_id "faq_text"]
                [pcdata "Privacy Policy of U.S. Charter Brokers LLC"];

                h3 ~a:[a_id "faq_text"]
                [pcdata "U.S. Charter Brokers LLC operates the https://www.uscharterbrokers.com website, which provides services for its customers and other users."];

                h3 ~a:[a_id "faq_text"]
                [pcdata "This page is used to inform website visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decided to use our Service, the U.S. Charter Brokers Website website."];

                h3 ~a:[a_id "faq_text"]
                [pcdata "If you choose to use our Service, then you agree to the collection and use of information in relation with this policy. The Personal Information that we collect are used for providing and improving the Service. We will not use or share your information with anyone except as described in this Privacy Policy."];

                h3 ~a:[a_id "faq_text"]
                [pcdata "The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at https://www.uscharterbrokers.com, unless otherwise defined in this Privacy Policy. Our Privacy Policy was created with the help of the Privacy Policy Template."];

                h2 ~a:[a_id "faq_text"]
                [pcdata "Information Collection and Use"];

                h3 ~a:[a_id "faq_text"]
                [pcdata "For a better experience while using our Service, we may require you to provide us with certain personally identifiable information, including but not limited to your name, phone number, and postal address. The information that we collect will be used to contact or identify you."];

                h2 ~a:[a_id "faq_text"]
                [pcdata "Log Data"];

                h3 ~a:[a_id "faq_text"]
                [pcdata "We want to inform you that whenever you visit our Service, we collect information that your browser sends to us that is called Log Data. This Log Data may include information such as your computer’s Internet Protocol (\"IP\") address, browser version, pages of our Service that you visit, the time and date of your visit, the time spent on those pages, and other statistics."];

                h2 ~a:[a_id "faq_text"]
                [pcdata "Cookies"];

                h3 ~a:[a_id "faq_text"]
                [pcdata "Cookies are files with small amount of data that is commonly used an anonymous unique identifier. These are sent to your browser from the website that you visit and are stored on your computer’s hard drive."];

                h3 ~a:[a_id "faq_text"]
                [pcdata "Our website uses these \"cookies\" to collection information and to improve our Service. You have the option to either accept or refuse these cookies, and know when a cookie is being sent to your computer. If you choose to refuse our cookies, you may not be able to use some portions of our Service."];

                h2 ~a:[a_id "faq_text"]
                [pcdata "Service Providers"];

                h3 ~a:[a_id "faq_text"]
                [pcdata "We may employ third-party companies and individuals due to the following reasons:"];

                h3 ~a:[a_id "faq_text"]
                    [pcdata "To facilitate our Service;"];

                h3 ~a:[a_id "faq_text"]
                    [pcdata "To provide the Service on our behalf;"];

                h3 ~a:[a_id "faq_text"]
                    [pcdata "To perform Service-related services; or"];

                h3 ~a:[a_id "faq_text"]
                    [pcdata "To assist us in analyzing how our Service is used."];

                h3 ~a:[a_id "faq_text"]
                [pcdata "We want to inform our Service users that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose."];

                h2 ~a:[a_id "faq_text"]
                [pcdata "Security"];

                h3 ~a:[a_id "faq_text"]
                [pcdata "We value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security."];

                h2 ~a:[a_id "faq_text"]
                [pcdata "Links to Other Sites"];

                h3 ~a:[a_id "faq_text"]
                [pcdata "Our Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites. We have no control over, and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services."];

                h2 ~a:[a_id "faq_text"]
                [pcdata "Children’s Privacy"];

                h3 ~a:[a_id "faq_text"]
                [pcdata "Our Services do not address anyone under the age of 13. We do not knowingly collect personal identifiable information from children under 13. In the case we discover that a child under 13 has provided us with personal information, we immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us so that we will be able to do necessary actions."];

                h2 ~a:[a_id "faq_text"]
                [pcdata "Changes to This Privacy Policy"];

                h3 ~a:[a_id "faq_text"]
                [pcdata "We may update our Privacy Policy from time to time. Thus, we advise you to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately, after they are posted on this page."];

                h2 ~a:[a_id "faq_text"]
                [pcdata "Contact Us"];

                h3 ~a:[a_id "faq_text"]
                [pcdata "If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us."];

              div ~a:[a_id "llc_footer"] [pcdata "U.S. Charter Brokers LLC"];
              div ~a:[a_id "disclaimer"] [pcdata "U.S. Charter Brokers LLC is an air charter broker, serving as an agent. U.S. Charter Brokers LLC does not own or operate any aircraft. All aircraft are operated by licensed and federally regulated Part 135 air charter operators."]
             ]

            ]
           ]

           ))))

let () =
  CharterBroker_app.register
    ~service:available_leg_service
    (fun () () ->
      Lwt.return
        (Eliom_tools.F.html
           ~title:"List available legs"
           ~css:[["css";"CharterBroker.css"]]
           ~other_head:other_head
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
    Lwt_io.print "\nWriting the data to the database:" >>
    Lwt_io.print ("\ndeparture_city: " ^ departure_city) >>
    Lwt_io.print ("\narrival_city: " ^ arrival_city) >>
    Lwt_io.print ("\ndeparture_year: " ^ string_of_int departure_year) >>
    Lwt_io.print ("\ndeparture_month: " ^ string_of_int departure_month) >>
    Lwt_io.print ("\ndeparture_day: " ^ string_of_int departure_day) >>
    Lwt_io.print ("\navailable_seats: " ^ available_seats) >>
    Lwt_io.print ("\naircraft_type: " ^ aircraft_type) >>
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
