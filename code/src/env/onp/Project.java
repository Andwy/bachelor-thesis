// CArtAgO artifact code for project onp
package onp;

import java.util.ArrayList;
import java.util.Random;

import cartago.*;
import jason.asSyntax.Atom;
import jason.asSyntax.Term;

public class Project extends Artifact {

  private Display display;
  private double fundRaised;
  private double fundTarget;
  private ArrayList<String> supporters;
  private String beneficiary;
  private String problem; //{MONEY | ASSISTANCE}
  private long ticks; //remaining ticks for raising fund
  private boolean counting;


  void init(double fundTarget, String beneficiary, String problem, String scheme) {
    this.counting = true;
    this.supporters = new ArrayList<String>();
    this.beneficiary= beneficiary;
    this.fundRaised = 0;
    this.problem = problem;

    Random r = new Random();

    if(fundTarget == 0)
      this.fundTarget = Double.MAX_VALUE;
    else {
      this.fundTarget = r.nextInt(500) +50;
    }

    this.ticks = r.nextInt(75) + 15;
    Term sch = new Atom(scheme);
    defineObsProperty("sch", sch);
    defineObsProperty("problem", problem);
    defineObsProperty("status", "ongoing", 0, 0);

    this.display = new Display(scheme, this.fundTarget, this.ticks, problem, beneficiary);

    execInternalOp("count");
    display.addText("PROJECT", "timer start...");
  }

  @OPERATION
  void getBeneficiary(OpFeedbackParam<Term> res){
    Term t = new Atom(this.beneficiary);
    res.set(t);
  }

  @OPERATION
  void donate(double dollars) {
    String ag = getCurrentOpAgentId().getAgentName();
    supporters.add(ag);
    display.addText(ag, "donate " + Math.round(dollars) + "$");
    this.fundRaised += Math.round(dollars);
    display.updateFund(this.fundRaised);

    if(fundRaised >= fundTarget) {
      this.counting = false;
      display.addText("PROJECT", "funded");
      display.setFunded();
      getObsProperty("status").updateValues("funded", fundTarget, fundRaised - fundTarget);
    }
  }

  @OPERATION
  void printMessage(String msg){
    String ag = getCurrentOpAgentId().getAgentName();
    display.addText(ag, msg);
  }

  @OPERATION
  void startTimer(){
    if(!this.counting) {
      execInternalOp("count");
      display.addText("PROJECT", "timer start...");
    }
  }

  @INTERNAL_OPERATION
  void count() {
    this.counting = true;
    while(this.counting) {
      await_time(Clock.TICK_TIME);
      ticks--;
      display.updateDeadline(ticks);
      if(ticks <= 0) {
        this.counting = false;
        display.addText("PROJECT", "failed");
        display.setFailed();
        getObsProperty("status").updateValues("failed", fundRaised, fundTarget - fundRaised);
      }
    }
  }
}
