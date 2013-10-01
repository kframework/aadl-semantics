require  "aadl_syntax.k"

module AADL-CONFIGURATION
	imports AADL-SYNTAX
	
configuration
	<cpu> 
		<id> 0 </id> 
		<state> 0 |-> 0 </state> // running thread: thread name |-> current priority
		<threads> 
			SyncThreads |-> 0  // for sync [2]
			ReadyThreads |-> 0 // for sync [1]
			SchedulingThreads |-> 0 // Scheduling Threads.
			PeriodicThreads |-> 0
			AperiodicThreads |-> 0
			SporadicThreads |-> 0
			TotalThreads |-> 0
		</threads> 
	</cpu>
	<component multiplicity="*"> // system architecture unit
		<comid> .Map </comid> // component: id, name, category, scheduled times
		<k> $PGM:K </k>
		// subcomponent: id, name, category. subcomponents belong to component, 
		<subcomponent multiplicity="*"> .Map </subcomponent>
		// port:
		<port multiplicity="*"> 
			<portid> .Map </portid> //  id, type, direction, data type
			<portdata> .Map </portdata>
			<portitemcount> 0 |-> 0 </portitemcount> // head |-> tail , tail entry, head out
			<portfresh> 0 </portfresh>
			<portdest> .Map </portdest> // dest-com-id |-> dest-port-id
		</port>
		<property> .Map </property> // Identifier |-> value
		<comclock> 0 </comclock> 
		<comstate> 0 |-> 0 </comstate> // current state |-> time left
										// state: 0 idle, 1 maybe idle, 2 waiting, 3 running, 4 want to run
		<executions> .Map </executions> // number executions: act |-> time
	</component>
	<behavior multiplicity="*">
		<componentid> noname </componentid> // Which component that behavior belong to.
		<states> .Map </states>
		<statevariables> .Map </statevariables>
		<store> .Map </store>
		<automata> 
			<automataid> NotInitialized </automataid>
			<automataclock> 0 </automataclock>
			<status> kidle </status>
			<curstate> 0 </curstate>
			<eventcount> 0 </eventcount> 
			<processingevent> .Map </processingevent> // number |-> state
			<event> .Map </event>
			<automatatable> .Map </automatatable> 	// match action
												// dport |-> (event, curstate, nextstate, activity)
		</automata>
	</behavior>
	
	<globalclock> <globaltime> 0 </globaltime> 
		<subclockcount> 0 |-> 0 kclear |-> 0 </subclockcount> // Total number |-> Current number ; Clear number
		<subclock> .Map </subclock> // serial number |-> subautomata id
	</globalclock>
	<warnning>  
		<timeout> .Map </timeout>  // thread id |-> Global time, state
	</warnning>

endmodule