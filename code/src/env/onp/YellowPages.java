// CArtAgO artifact code for project onp_project
package onp;

import java.util.ArrayList;
import java.util.Random;
import cartago.*;
import jason.asSyntax.Atom;
import jason.asSyntax.Term;

public class YellowPages extends Artifact {
	private ArrayList<String> contacts; // citizens + volunteers + poors
	private ArrayList<String> citizens; // only citizen

	void init() {
		contacts = new ArrayList<String>();
		citizens = new ArrayList<String>();

		defineObsProperty("recruitment_permission", true);
	}

	@OPERATION
	void register() {
		String agent = getCurrentOpAgentId().getAgentName();
		if(!contacts.contains(agent)) {
			contacts.add(agent);
			citizens.add(agent);
		}
	}

	@OPERATION
	void randomCitizen(OpFeedbackParam<Term> res) {
		if(citizens.size() == 0)
			failed("YP-Error","no registered agents");
		else {
			Random random = new Random();
		 	String ag = citizens.get(random.nextInt(citizens.size()));
		 	Term t = new Atom(ag);
		 	res.set(t);
		}
	}

	@OPERATION
	void randomContact(OpFeedbackParam<Term> res) {
		if(citizens.size() == 0)
			failed("YP-Error","no registered agents");
		else {
			Random random = new Random();
			String ag = contacts.get(random.nextInt(contacts.size()));
			while(ag.equals(getCurrentOpAgentId().getAgentName()))
				ag = contacts.get(random.nextInt(contacts.size()));
		 	Term t = new Atom(ag);
		 	res.set(t);
		}
	}

	@OPERATION
	void startVolunteering() {
		String ag = getCurrentOpAgentId().getAgentName();
		citizens.remove(ag);
		if(citizens.size() < contacts.size()/2)
			getObsProperty("recruitment_permission").updateValue(false);
	}

	@OPERATION
	void exitVolunteering() {
		String ag = getCurrentOpAgentId().getAgentName();
		if(!citizens.contains(ag))
			citizens.add(ag);
		if(citizens.size() >= contacts.size()/2)
			getObsProperty("recruitment_permission").updateValue(true);
	}

	@OPERATION
	void printEntry() {
		System.out.println("YELLOW PAGES - Contacts");
		for(String s : contacts)
			System.out.println("\t" + s);
		System.out.println("YELLOW PAGES - Citizens (no volunteer)");
		for(String s : citizens)
			System.out.println("\t" + s);
	}
}
