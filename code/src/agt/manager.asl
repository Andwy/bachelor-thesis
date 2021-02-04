/* Initial beliefs and rules */
ongoing(0).
money(6000). // onp's (exceeding) budget
fundraising.

/* Initial goals */

!org_setup.

/* Plans */

+!org_setup
  : org_ws(WS) & org_name(Org) & group_name(Group)
 <- createWorkspace(WS);
    joinWorkspace(WS, WOrg);

    makeArtifact(Org, "ora4mas.nopl.OrgBoard", ["src/org/org-spec.xml"], OrgArtId)[wid(WOrg)];
    createGroup(Group, onp_group, GrArtId);
    createScheme(onp_scheme, main_scheme, SchArtId);
    !inspector(GrArtId);
    !inspector(SchArtId);

    focus(OrgArtId)[wid(WOrg)];
    focus(GrArtId)[wid(WOrg)];
    focus(SchArtId)[wid(WOrg)];

    adoptRole(manager)[artifact_id(GrArtId)];
    addScheme(onp_scheme)[artifact_id(GrArtId)];
    commitMission(management)[artifact_id(SchArtId)]
    .print("O.N.P. created").

+obligation(Ag, Norm, What, Deadline)[artifact_id(ArtId)]
  : .my_name(Ag)
     & (satisfied(Scheme, Goal) = What | done(Scheme, Goal, Ag) = What)
 <- .print(Scheme, " - ", Goal);
   	!Goal[scheme(Scheme)].

/* Organization's Goal: main_scheme */

+!init[scheme(Scheme)]
  : workspace(WS) & art_yp(Y) & art_c(C)
 <- createWorkspace(WS);
    !discover_workspace(_);
    makeArtifact(Y, "onp.YellowPages", [], Yid);
    makeArtifact(C, "onp.Clock", [], Cid);
    startClock[artifact_id(Cid)]; //artifact Clock's operation
    goalAchieved(init)[artifact_name(Scheme)].

+!hire_staff[scheme(Scheme)]
 <- .wait(500);
    .send(coordinator, achieve, hire(coordinator));
    goalAchieved(hire_staff)[artifact_name(Scheme)].

/* Maintenance Goal: starting point */
+goalState(_, create_project, _, _,enabled)
  : goalState(_,hire_staff, _, _,satisfied)
 <- .my_name(Me);
    !!create_project(fundraising, 0, Me, money).

// belief from operator
+candidate(Ag, Trouble)
 <- !!create_project(Ag, math.random * 1000 + 300, Ag, Trouble).

+money(M)
  : M < 300 & not fundraising
 <- .my_name(Me);
 	+fundraising;
    !!create_project(fundraising, 0, Me, money).


@maintenance_goal[atomic]
+!create_project(P, Target, Beneficiary, Problem)
  : org_ws(WS) & joined(WS, WOrg)
 <- ?ongoing(N)
    .concat(P, "_", N, PrName);
    .concat("sch_", PrName, Scheme);

    makeArtifact(PrName, "onp.Project", [Target, Beneficiary, Problem, Scheme], ArtPr);
    focus(ArtPr);
    createScheme(Scheme, project_scheme, SchArtId);
    !inspector(SchArtId);
    setArgumentValue(fund_project, "project_art", PrName)[artifact_id(SchArtId)];
    addScheme(Scheme);
    focus(SchArtId)[wid(WOrg)];
    -+ongoing(N+1);
    .print("created new project: ", PrName);
    commitMission(mFund)[artifact_id(SchArtId)].

+!raise_fund[scheme(Scheme)]
 <- .print("We have beaten poverty");
 	goalAchieved(raise_fund)[artifact_name(Scheme)].

+!help_people[scheme(Scheme)]
 <- goalAchieved(help_people)[artifact_name(Scheme)].

/* Organization's Goal: project_scheme */

sch_agents(P) :- .concat("sch_", P, Scheme)
              & goalState(Scheme, awareness, CommittedAgents, _, _)
              & .length(CommittedAgents, L) & L \== 0.

////the manager try to save the scheme (if there are some operators)
//+status("failed", FundRaised, MissingFund)[artifact_name(_, Project)]
//  : money(M) & MissingFund < M & sch_agents(Project)
// <- !transfer_money(MissingFund, Project);
// 	printMessage("O.N.P. saves the project")[artifact_name(_, Project)]
//    .print("O.N.P. saves the project: ", Project).

+!fund_project[scheme(Scheme)]
 : status("failed", FundRaised, MissingFund)[artifact_name(_, Project)]
 <- .print("the project ", Project, " is failed");
    ?money(M);
    -+money(M + FundRaised);
    getBeneficiary(B)[artifact_name(Project)];
    .send(B, tell, project_failed);
    goalAchieved(fund_project)[artifact_name(Scheme)];
    !destroy_sch[scheme(Scheme)].

 +!fund_project[scheme(Scheme)]
 : status("funded", FundTarget, Exceeding)[artifact_name(_, Project)]
 <- .print("the scheme ", Scheme, " is completed");
    ?money(M);
    -+money(M + Exceeding);
	goalAchieved(fund_project)[artifact_name(Scheme)];
	!destroy_sch[scheme(Scheme)].

+!destroy_sch[scheme(Scheme)]
 <- goalAchieved(transfer_fund)[artifact_name(Scheme)];
 	leaveMission(mFund)[artifact_name(Scheme)];
	destroy[artifact_name(Scheme)];
	.

+!fund_project[scheme(Scheme)]
 <- .print("mFund - Error: project is ongoing").

//failed project management - the manager try to save the scheme (if there are some operators)
+!transfer_fund[scheme(PrSch)]
  : goalArgument(PrSch, fund_project, "project_art", Project)
    & status("ongoing", _, _)[artifact_name(_, Project)]
 <- .wait(3000);
 	.print("STATUS ONGOING, ", Project);
// 	resetGoal(complete_project)[artifact_name(PrSch)].
	!transfer_fund[scheme(PrSch)].

//failed project management
+!transfer_fund[scheme(PrSch)]
  : status("failed", FundRaised, MissingFund)[artifact_name(_, Project)]
  & money(M) & MissingFund < M //& sch_agents(Project)
 <- !transfer_money(MissingFund, Project);
    .print("O.N.P. saves the project: ", Project)
    !transfer_fund[scheme(PrSch)].

+!transfer_fund[scheme(PrSch)]
  : goalArgument(PrSch, fund_project, "project_art", Project)[workspace(_, _, Wid)]
    & problem("money")[artifact_name(_, Project)]
 <- !transfer_aux(Project);
    goalAchieved(transfer_fund)[artifact_name(PrSch), wid(Wid)].

+!transfer_fund <- .print("non faccio nulla").

+!transfer_aux(Project)
  : status("funded", FundTarget, Exceeding)[artifact_name(_, Project)]
 <-  getBeneficiary(B)[artifact_name(Project)];
    .send(B, tell, bank_transfer(FundTarget))
    .print("Transferred ", FundTarget, "$ to ", B).

+!transfer_aux(Project) <- true.

+!execute_task[scheme(Scheme)]
 <- goalAchieved(execute_task)[artifact_name(Scheme)].

+!complete_project[scheme(PrSch)]
  : goalArgument(PrSch, fund_project, "project_art", Project)[workspace(_, _, Wid)]
    & problem("assistance")[artifact_name(_, Project)]
 <- getBeneficiary(B)[artifact_name(Project)];
 	.print(B, " is not in trouble");
    .send(B, tell, assistance);

    goalAchieved(complete_project)[artifact_name(PrSch), wid(Wid)].

+!complete_project[scheme(Scheme)]
 <- goalAchieved(complete_project)[artifact_name(Scheme)].

+project_failed
 <- -project_failed;
 	-fundraising.

{ include("default-behaviour.asl") }
