import AccessControl "mo:caffeineai-authorization/access-control";
import MixinAuthorization "mo:caffeineai-authorization/MixinAuthorization";
import Principal "mo:core/Principal";
import OQL "mo:caffeineai-oql";
import Expose "mo:caffeineai-oql/Expose";
import Entity "mo:caffeineai-oql/Entity";
import PrincipalValue "mo:caffeineai-oql/PrincipalValue";
import TextValue "mo:caffeineai-oql/TextValue";

actor {
  let accessControlState : AccessControl.AccessControlState;
  include MixinAuthorization(accessControlState, null);

  // OQL (Data Intelligence) — exposes schema() and execute(qJson) query methods
  // required by the deploy. The only persisted, queryable collection is the
  // access-control user-role map; it is exposed as a single `userRole` entity
  // at the default #controllerOnly level (private to users, readable by the
  // Data Intelligence agent acting as the controller). UserRole is a variant,
  // so the entity is built in manual mode over the map's entries, promoting
  // the Principal key to a `user` column and rendering the role tag as text.
  include Expose({
    entities = [
      Entity.manual<(Principal, AccessControl.UserRole)>(
        "userRole",
        func() = accessControlState.userRoles.entries(),
        "UserRoleAssignment",
        "user",
      )
        .payload("user", func((p, _)) = p)
        .payload("role", func((_, r)) = switch r {
          case (#admin) "admin";
          case (#user) "user";
          case (#guest) "guest";
        })
        .controllerOnly()
        .build(),
    ];
  });
};
