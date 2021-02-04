/* organizational goal for role operator - project_scheme */

+obligation(Ag, Norm, done(Scheme, Goal, Ag), Deadline)
  : .my_name(Ag)
 <- !!Goal[scheme(Scheme)].

+!awareness[scheme(PrSch)]
  : goalArgument(PrSch, fund_project, "project_art", Project)
    & status("ongoing", _, _)[artifact_name(_, Project)]
 <- waitTicks(2); // artifact Clock's operation
    randomContact(Ag);
    ?goalArgument(PrSch, fund_project, "project_art", Project);
    .send(Ag, achieve, persuade(Project));
    !!awareness[scheme(PrSch)].

+!awareness[scheme(Scheme)]
 <- goalAchieved(awareness)[artifact_name(Scheme)].

+goalState(Scheme, complete_project, _, _,satisfied)
 <-  leaveMission(mAware)[artifact_name(Scheme)];
     leaveMission(mTask)[artifact_name(Scheme)].

+!assistance[scheme(Scheme)]
  : goalArgument(Scheme, fund_project, "project_art", Project)[workspace(_, _, Wid)]
 <- goalAchieved(assistance)[artifact_name(Scheme), wid(Wid)].

+!assistance[scheme(Scheme)] <- leaveMission(mTask)[artifact_name(Scheme)].

/* belief from a citizen with trouble(T) */
+help(Trouble)[source(Ag)]
  <- .send(manager, tell, candidate(Ag, Trouble)).

/* belief from artifact project */
+problem("assistance")[artifact_name(_, Project)]
 <- ?goalArgument(Scheme, fund_project, "project_art", Project)[workspace(_, WS, _)];
    commitMission(mTask)[wsp(WS), artifact_name(Scheme)].
