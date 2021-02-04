{ include("default-behaviour.asl") }

{ include("$jacamoJar/templates/common-moise.asl") }
{ include("template/org-obedient.asl") }

//intention from the manager
+!hire(Role)
 <- ?art_yp(YP); !discover_art(YP);
    ?art_c(C); !discover_art(C);
    !join_org_as(Role).

//to focus on the corresponding (project) artifact of a (project) scheme
+goalArgument(Scheme, fund_project, "project_art", Project)
 <- !discover_art(Project).

//project scheme (un)fulfillment handler
+status(S, _, _)[artifact_name(_, Project)]
 : S \== "ongoing" & sch(PrSch)[artifact_name(PrId, Project)]
  & commitment(coordinator, mCoord, PrSch)
 <- !satisfy_org_goal(Project, PrSch);
 	stopFocus(PrId);
    leaveMission(mCoord)[artifact_name(PrSch)].
/* the failure of a goal (and scheme) in Jacamo 0.8 cannot be modeled correctly:
 * solutions: the agents committed to the scheme achieve their goal,
 *            then the manager can handle the failure (new belief)artifact_name(Sch)
 */

@s1[atomic]
+!satisfy_org_goal(Project, Sch)
  : not goalState(Sch, coordination, _, _, satisfied)
 <- goalAchieved(assignment)[artifact_name(Sch)];
    goalAchieved(recruitment)[artifact_name(Sch)];
    goalAchieved(coordination)[artifact_name(Sch)];
    //drop all intentions related to the scheme
    .drop_intention(assignment[scheme(Sch)]);
    .drop_intention(recruitment[scheme(Sch)]);
    .drop_intention(coordination[scheme(Sch)]).

+!satisfy_org_goal(Project, Sch)
 <- true.

/* organizational goal for role coordinator - project_scheme */

//every project have 3 volunteers (max 2 reassigned)
@org1
+!coordination <- true.

//try to assign 2 volunteeers to the scheme Sch
@org2[atomic]
+!assignment[scheme(Sch)]
 <- .findall(Ag, play(Ag, operator, _), List);
    !assign(2, List)[scheme(Sch)].

+!assignment[scheme(Sch)]
 <- .print(Sch, " - there aren't any available operator").

+!assign(N, List)[scheme(Sch)]
 : not .empty(List) & N > 0
 <- .nth(0, List, Ag);
    .delete(Ag, List, L);
    .send(Ag, tell, hire_vol(operator, "mAware", Sch));
    waitTicks(2); //artifact Clock's operation
    !assign_aux(Ag, N, L)[scheme(Sch)].

+!assign(N, _)[scheme(Sch)]
 <- .print(Sch, " - assigned to the scheme ", 2-N, " volunteers").

+!assign_aux(Ag, N, List)[scheme(Sch)]
  : goalState(Sch, awareness, CommittedAgents, _, _) & .member(Ag, CommittedAgents)
 <- //.print("assigned ", Ag, " to ", Sch);
    !assign(N-1, List)[scheme(Sch)].

+!assign_aux(Ag, N, List)[scheme(Sch)]
 <- !assign(N, List)[scheme(Sch)].

//recruite 3-(assigned_operator) citizen
+!recruitment[scheme(Sch)]
  : recruitment_permission(true) //YellowPages' observable property
    & .findall(Ag, commitment(Ag, mAware, Sch), Committed)
    & .length(Committed, L)
 <- !recruite(3-L)[scheme(Sch)];
 	.print(Sch, " - recruit ", 3-L, " citizen").

+!recruitment[scheme(Sch)]
 <- .print(Sch, " - cannot recruit more then half of all citizens").

+!recruite(N)[scheme(Sch)]
  : N > 0
 <- randomCitizen(Ag); //YellowPages' operation
    .send(Ag, tell, hire_vol(operator, "mAware", Sch));
    waitTicks(2); //Clock' observable property
    !recruite_aux(Ag, N)[scheme(Sch)].

-!recruite(N)[scheme(Sch)]
 <- .print(Sch, " > error: there aren't any citizen");
 	.wait(3000);
 	!recruitment[scheme(Sch)].

@recruitment_exit1[atomic]
+!recruite(0)[scheme(Sch)]
  : goalArgument(Scheme, fund_project, "project_art", Project)
 <- .print(Sch, " - fundrising start...");
    .

+!recruite(0)[scheme(Sch)]
 <- .print(Sch, " - Timer not set").

+!recruite_aux(Ag, N)[scheme(Sch)]
  : //play(Ag, operator, _)
  	commitment(Ag, mAware, Sch)
 <- //.print(Ag, " hired");
    !recruite(N-1)[scheme(Sch)].

+!recruite_aux(Ag, N)[scheme(Sch)]
 <- !recruite(N)[scheme(Sch)].
