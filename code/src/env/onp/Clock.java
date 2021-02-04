// CArtAgO artifact code for project onp
package onp;
import cartago.*;


public class Clock extends Artifact {
	private boolean counting;
	private int ticks;
	public static final long TICK_TIME = 700;

	void init() {
		counting = false;
		ticks = 0;
	}

	@OPERATION
	void startClock() {
		if(!counting) {
			counting = true;
			execInternalOp("count");
		} else {
			failed("already counting");
		}
	}

	@OPERATION
	void stopClock() {
		counting = false;
	}

	@OPERATION
	void resetClock() {
		ticks = 0;
	}

	@INTERNAL_OPERATION
	void count() {
		while(counting) {
			await_time(TICK_TIME);
			this.ticks++;
			if(ticks % 10 == 0)
				signal("ticks");
		}
	}

	@OPERATION
	void waitTicks(int t) {
		while(t > 0) {
			await_time(TICK_TIME);
			t--;
		}
	}

}
