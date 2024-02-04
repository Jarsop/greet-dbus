let service_name = "je.sappel.Greet"
let name_ref = ref "Groot"

type t = {
  obus : t OBus_object.t;
  name : string React.signal;
  set_name : string -> unit;
}

module Je_Sappel_Greet = struct
  let interface = "je.sappel.Greet"

  let m_Greet =
    {
      OBus_member.Method.interface;
      OBus_member.Method.member = "Greet";
      OBus_member.Method.i_args =
        OBus_value.arg1 (None, OBus_value.C.basic_string);
      OBus_member.Method.o_args = OBus_value.arg0;
      OBus_member.Method.annotations = [];
    }

  let p_Name =
    {
      OBus_member.Property.interface;
      OBus_member.Property.member = "Name";
      OBus_member.Property.typ = OBus_value.C.basic_string;
      OBus_member.Property.access = OBus_member.Property.readable;
      OBus_member.Property.annotations = [];
    }

  type 'a members = {
    m_Greet : 'a OBus_object.t -> string -> unit Lwt.t;
    p_Name : 'a OBus_object.t -> string React.signal;
  }

  let make members =
    OBus_object.make_interface_unsafe interface []
      [| OBus_object.method_info m_Greet members.m_Greet |]
      [||]
      [| OBus_object.property_r_info p_Name members.p_Name |]
end

let greet obj new_name =
  obj.set_name new_name;
  Lwt.return_unit

let interface =
  Je_Sappel_Greet.make
    {
      Je_Sappel_Greet.m_Greet =
        (fun obj name -> greet (OBus_object.get obj) name);
      Je_Sappel_Greet.p_Name = (fun obj -> (OBus_object.get obj).name);
    }

let () =
  Lwt_main.run
    (let%lwt bus = OBus_bus.session () in
     let%lwt _ = OBus_bus.request_name bus service_name in
     let name, set_name = React.S.create "Groot" in
     let obj =
       {
         obus =
           OBus_object.make ~interfaces:[ interface ]
             [ "je"; "sappel"; "Greet" ];
         name;
         set_name;
       }
     in
     OBus_object.attach obj.obus obj;
     OBus_object.export bus obj.obus;
     flush stdout;
     fst (Lwt.wait ()))
