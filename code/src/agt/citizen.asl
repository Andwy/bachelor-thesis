// Agent citizen in project onp
{ include("default-behaviour.asl") }
{ include("operator.asl") }

{ include("$jacamoJar/templates/common-moise.asl") }

/* Initial beliefs and rules */
altruism(0). //probability for a donation
money(0).

/* Initial goals */

!start.

/* Plans */

+!start
 <- ?art_yp(YP);
    !discover_art(YP);
    register; //artifact YellowPages' operation
    !work.

+!work
  : not trouble(_)
 <- ?art_c(C);
    !discover_art(C).

+!work <- true.

/* signal from artifact Clock */
@work[atomic]
+ticks
  : not trouble(_) & money(M) & M <= 600
 <- ?money(M);
    -+money(M + math.random * 100 + 5).

+ticks <- true.

/* belief sent by coordinator */
+hire_vol(Role, Mission, PrSch)[source(coordinator)]
  : not trouble(_) //& not play(Role, PrSch)
 <- !join_org_as(Role);
    startVolunteering; // artifact YellowPages' operation
    !commit(Mission, PrSch);
    -hire_vol(Role, Mission, PrSch)[source(coordinator)].

+hire_vol(Role, Mission, PrSch)[source(Ag)]
 <- -hire_vol(Role, Mission, PrSch)[source(Ag)].

//commit to mission, only if the goals are not satisfied
+!commit(Mission, PrSch)
  : focused(_, PrSch, _) & not goalState(PrSch, awareness, _, _,satisfied)
 <- commitMission(Mission)[artifact_name(PrSch)];
	!discover_project(PrSch).

+!commit(_, _) <- true.
-!commit(_, _) <- .print("error: cannot commit to the scheme").

/* belief sent by other volunteers */
@ptrouble[atomic]
+!persuade(Project)[source(Ag)]
  : trouble(X) & not contacted
 <- .send(Ag, tell, help(X));
    +contacted;
    -persuade(Project)[source(Ag)].

@pnormal[atomic]
+!persuade(Project)[source(Ag)]
  : not trouble(_)
 <- -persuade(Project)[source(Ag)];
    ?altruism(X); -+altruism(X+10);
    !new_donation((math.random * 100) + 1, Project).

+!persuade(_) <- true.

+!new_donation(Success, Project)
  : money(M) & M >= 1000
 <- !transfer_money(M * 0.5, Project);
  	-+altruism(0).

+!new_donation(Success, Project)
  : altruism(X) & money(M) & M > 0 & Success < X
 <- !transfer_money(M * 0.2, Project);
    -+altruism(0).

+!new_donation(_, _) <- true.

/* belief from the manager for citizen in trouble */
+assistance[source(manager)]
 <- .print("I don't have any trouble. I can work!!!");
    -trouble(assistance);
    -assistance[source(manager)];
    !work.

+project_failed[source(manager)]
 <- -project_failed[source(manager)];
    -contacted.

+bank_transfer(Dollars)[source(manager)]
 <- .print("I don't have any trouble. I can work!!!");
 	  -+money(0);
    -bank_transfer(Dollars)[source(manager)];
    -trouble(money).
