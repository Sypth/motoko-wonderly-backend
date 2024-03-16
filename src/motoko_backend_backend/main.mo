import Map "mo:map/Map";
import { phash } "mo:map/Map";
import { thash } "mo:map/Map";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Float "mo:base/Float";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Source "mo:uuid/async/SourceV4";
import UUID "mo:uuid/UUID";

actor Wonderly{
  type MessageResult = {
    message : Text;
  };

  type User = {
    id : ?Text;
    firstName : Text;
    middleName : ?Text;
    lastName : Text;
    gender : Text;
    birthDate : Text;
    address : Text;
    email: Text;
    contact : Nat;
    achievementsId: ?Text;
    points : Float;
  };

  type Achievement = {
    emoji : Text;
    title : Text;
    description : Text;
    multiplier : Float;
    tradable : Bool;
  };

  type UserAchievement = {
    userId : Text;
    fullName : Text;
    achievementList : [Achievement];
  };

  func generateUUID() : async Text {
    let g = Source.Source();
    return UUID.toText(await g.new());
  };


  stable let users = Map.new<Principal, User>();
  stable let achivementList = Map.new<Text, Achievement>();
  stable let userAchievements = Map.new<Text, Achievement>();


  public shared ({ caller }) func createUser(payload : User) : async Result.Result<MessageResult and { id : Text }, MessageResult>{
    // if(Principal.isAnonymous(caller)){
    //   return #err({ message = "Anonymous identity found!" });
    // };

    // Generate user id
    let userId : Text = do {
      switch (payload.id) {
        case (null) {
          await generateUUID();
        };
        case (?id) {
          id;
        };
      };
    };

    // Generate user achievements id
    let achievementsId : Text = do {
      switch (payload.id) {
        case (null) {
          await generateUUID();
        };
        case (?id) {
          id;
        };
      };
    };

    let newUser : User = {
      id = ?userId;
      firstName = payload.firstName;
      middleName = payload.middleName;
      lastName = payload.lastName;
      gender = payload.gender;
      birthDate = payload.birthDate;
      address = payload.address;
      email = payload.email;
      contact = payload.contact;
      achievementsId = ?achievementsId;
      points = 0.0;
    };

    // Create new user
    switch (Map.add(users, phash, caller, newUser)) {
      case (null) {
        return #ok({
          message = "User account created successfully!";
          id = userId;
        });
      };
      case (?user) {
        return #err({ message = "User already exists!" });
      };
    };
  };

  public func getUser(principal : Principal) : async Result.Result<User, MessageResult> {
    switch (Map.get(users, phash, principal)) {
      case (null) {
        return #err({ message = "No student found" });
      };
      case (?user) {
        return #ok(user);
      };
    };
  };


};
