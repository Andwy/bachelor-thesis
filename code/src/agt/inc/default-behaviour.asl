{ include("$jacamoJar/templates/common-cartago.asl") }

debug(true).

// organization's data
org_name(foundation).
group_name(team).
org_ws(ora4mas).

workspace("environment").
art_yp(yellowpages).
art_c(clock).

+!debug(Msg)
  : debug(true)
 <- .println(Msg).

+!inspector(ArtId)
  : debug(true)
 <- debug(inspector_gui(on))[artifact_id(ArtId)].
+!inspector(ArtId) <- true.

play(Role) :- .my_name(Ag) & play(Ag, Role, _).

@join[atomic]
+!join_org_as(Role)
  : org_ws(WS) & group_name(Group) & not play(Role)
 <- joinWorkspace(WS, WOrg);
    lookupArtifact(Group, ArtGr);
    focus(ArtGr)[wid(WOrg)];
    adoptRole(Role).

+!join_org_as(Role)
<- .print("I become ", Role).

-!join_org_as(Role)
    <-  .print("organization not available");
        .wait(5000);
        !join_org_as(Role).

@art1[atomic]
+!discover_project(PrSch)
  : goalArgument(PrSch, fund_project, "project_art", Project)
 <- !discover_art(Project).

+!discover_project(PrSch)
  <- .print("project for scheme ", PrSch, " not found").

// try to find a particular artifact and then focus on it
+!discover_art(ArtName)
   <- !discover_workspace(WId);
   	  lookupArtifact(ArtName, ArtId)[wid(WId)];
      focus(ArtId).

// keep trying until the artifact is found
-!discover_art(ArtName)
   <- .print(ArtName, " not found");
      .wait(1000);
      !discover_art(ArtName).

+!leave_art(ArtName)
   : focused(_, ArtName, ArtId)
  <- stopFocus(ArtId).

+!discover_workspace(Id)
  : workspace(WS) & not joined(WS, _)
 <- joinWorkspace(WS, Id).

+!discover_workspace(Id)
  : workspace(WS)
 <- ?joined(WS, Id).

-!discover_workspace(Id)
 <- .wait(1000);
    //.print("workspace not found");
    !discover_workspace(Id).

+!transfer_money(Money, Project)
 : money(M) & M > Money
 <- donate(Money)[artifact_name(Project)];
    //.print("I make a donation to ", Project);
    -+money(M - Money)
    .

+!transfer_money(Money, Project)
 <- .print("I don't have ", Money, "$").
