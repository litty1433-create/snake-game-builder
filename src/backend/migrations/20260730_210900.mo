import Map "mo:core/Map";
import Principal "mo:core/Principal";

module {
  // First migration: introduce the access-control stable state.
  // OldActor is {} because no prior version of this actor had stable state.
  type OldActor = {};

  // NewActor mirrors the stable fields declared in main.mo.
  // AccessControlState is inlined here (no project imports) so this
  // migration stays self-contained and replays correctly forever.
  type UserRole = {
    #admin;
    #user;
    #guest;
  };

  type AccessControlState = {
    var adminAssigned : Bool;
    userRoles : Map.Map<Principal, UserRole>;
  };

  type NewActor = {
    var accessControlState : AccessControlState;
  };

  public func migration(old : OldActor) : NewActor {
    {
      var accessControlState = {
        var adminAssigned = false;
        userRoles = Map.empty();
      };
    };
  };
};
