package onp;

import java.awt.Color;
import java.awt.FlowLayout;
import java.util.Random;
import javax.swing.*;

/** (very) simple UI to show how the agent's action modify a project **/
public class Display extends JFrame {
	private JTextArea text;
	private JScrollPane scrollableTextArea;

	private JLabel fundRaised;
	private double fundTarget;
	private JLabel deadline;

	public Display(String title, double target, long deadline, String problem, String beneficiary){
		setTitle("PROJECT: " + title);
		setSize(350, 400);

		JPanel panel = new JPanel();
		setContentPane(panel);

		this.fundTarget = Math.round(target);
		this.text = new JTextArea(15,1);
		this.text.setEditable(false);
		this.scrollableTextArea = new JScrollPane(text);

		panel.setLayout(new BoxLayout(panel,BoxLayout.Y_AXIS));

		JLabel l1 = new JLabel("Task: ");
		l1.setForeground(Color.red);
		JLabel l2 = new JLabel(problem);

		this.fundRaised = new JLabel(0 + "$");
		this.fundRaised.setForeground(Color.blue);

		JLabel tot = new JLabel("");
		if(fundTarget < 100000) {
			tot.setText(" - target: " + this.fundTarget + "$");
			tot.setForeground(Color.darkGray);
		}

		JLabel b1 = new JLabel("Beneficiary: ");
		b1.setForeground(Color.red);
		JLabel b2 = new JLabel(beneficiary);

		this.deadline = new JLabel(deadline + " ticks left");
		this.deadline.setForeground(Color.darkGray);

		panel.add(this.scrollableTextArea);
		panel.add(generateRow(this.fundRaised, tot));
		panel.add(generateRow(l1, l2));
		panel.add(generateRow(b1, b2));
		panel.add(generateRow(this.deadline, new JLabel()));

		Random r = new Random();
		int x = r.nextInt(800);
		int y = r.nextInt(500);

		setLocation(x, y);
		setVisible(true);
	}

	private JPanel generateRow(JLabel a, JLabel b) {
		JPanel p = new JPanel();
		p.setLayout(new FlowLayout(FlowLayout.LEFT, 1, 1));
		p.add(a);
		p.add(b);
		return p;
	}

	public void addText(final String agent, final String s){
		SwingUtilities.invokeLater(new Runnable(){
			public void run() {
				text.append("[" + agent + "]: " + s + "\n");
			}
		});
	}

	public void updateFund(final double value){
		SwingUtilities.invokeLater(new Runnable(){
			public void run() {
				fundRaised.setText(Math.round(value) + "$");
			}
		});
	}

	public void updateDeadline(final long value){
		SwingUtilities.invokeLater(new Runnable(){
			public void run() {
				deadline.setText(value + " ticks left");
			}
		});
	}

	public void setFunded() {
		SwingUtilities.invokeLater(new Runnable(){
			public void run() {
				deadline.setForeground(Color.green);
				deadline.setText("PROJECT FUNDED");
			}
		});
	}

	public void setFailed() {
		SwingUtilities.invokeLater(new Runnable(){
			public void run() {
				deadline.setForeground(Color.red);
				deadline.setText("PROJECT FAILED");
			}
		});
	}
}
