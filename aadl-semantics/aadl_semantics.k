require  "aadl_syntax.k"
require  "aadl_configuration.k"
module AADL-SEMANTICS
	imports AADL-CONFIGURATION
	imports AADL-SYNTAX
	
	syntax KResult ::= #Int | #Bool

	rule Com1:ComponentClassifier Com2:ComponentClassifier => Com1 ~> Com2  [structural]
	
	// thread, counts the number of threads
	rule <component>
			<k> thread Comid:Identifier Ct:ComponentType end Comid ; => . ...</k>
			...
		</component>
		<cpu> 
			<threads> TotalThreads |-> (I:Int => I +Int 1) ...</threads> 
			... 
		</cpu>
		(. => <component> 
			...
			<comid> 
				id |-> Comid 
				name |-> noname 
				category |-> thread
				ScheduledTimes |-> 0
			</comid>
			<k> Ct </k> 
			<comclock> 0 </comclock> 
			... 
		</component> 
		)

	// process
	rule <component><k> process Comid:Identifier Ct:ComponentType end Comid ; => . ...</k>...</component>
			(. => <component> ...<comid> id|->Comid name|->noname category|-> process </comid>
			<k> Ct </k>... </component> )

	// empty definition
	rule <component><k> ComCategory:ComponentCategory Comid:Identifier end Comid ; 
			=> . ...</k> ... </component>
			(. => <component> ...<comid> id|->Comid name|->noname category|->ComCategory </comid>
			<k> . </k>... </component> )
			
	// main component(comid cell is .Map). ONLY one. 当主组件和子组件k cell都为空时
	rule <component><comid> .Map </comid><k> . </k> ... </component>
			<component> ...<comid> id |-> Comid:Identifier ... </comid> <k> . </k>
			... </component>
			<automata><automataid> Comid </automataid> <status> kpending => kidle </status> ... </automata>
			<globalclock> 
				<subclockcount> ... kclear |-> (C:Int => C +Int 1) </subclockcount> // Total number |-> Current number
				<subclock> _ |-> Comid ... </subclock>...
			</globalclock>

	rule Ct1:ComponentType Ct2:ComponentType => Ct1 ~> Ct2 [structural]

	rule Ct:ClauseType C:Clause => C   		[structural]
	rule C1:Clause C2:Clause => C1 ~> C2 	[structural]
	
	// port
	rule <component><k>Pid:Identifier : Pd:PortDirection Pt:PortType Dbp:DataBehaviorPrefix 
			Dt:DataType; => . ...</k> 
			(. => <port> <portid> id|->Pid type|->Pt direction|->Pd datatype|-> Dt </portid>
			<portdata> 0 |-> test </portdata>	<portitemcount> 0 |-> 1 </portitemcount> <portfresh> 0 </portfresh>
			... </port>) ... </component>

	// implementation
	rule <component><k> ComCategory:ComponentCategory implementation ComId:Identifier ComImplSuffix:ComponentImplSuffix
							ComType:ComponentType end ComImplId:ComponentImplIdentifier ;
				=> . ...   </k> ...</component> <component> <comid> id|->ComId ... </comid>
				<k>... . => ComType </k> ... </component>
	rule ComCategory:ComponentCategory implementation ComId:Identifier ComImplSuffix:ComponentImplSuffix
							end ComImplId:ComponentImplIdentifier ;	=> .

	// one way connection
	// connection: sc.sp -> dc.dp
/*	rule <component> <k> ConId:Identifier : Pt:PortType CidS:Identifier . PidS:Identifier 
			Dir:ConnectSymbol CidD:Identifier . PidD:Identifier; => . ... </k> 
			(. => <connection> <conid>id|->ConId type|-> Pt direction|->Dir </conid> <concom> 
			CidS|->CidD</concom> <conport> PidS|->PidD </conport></connection>) ... </component>*/
	rule <component> <k> ConId:Identifier : Pt:PortType CidS:Identifier . PidS:Identifier 
			Dir:ConnectSymbol CidD:Identifier . PidD:Identifier; => . ... </k> 
			<subcomponent> id |-> CidS name |-> CnameS:Identifier ... </subcomponent>
			<subcomponent> id |-> CidD name |-> CnameD:Identifier ... </subcomponent>  ... </component>
			<component> <comid> id|-> CnameS ... </comid> <port> <portid> id |-> PidS ... </portid> 
			<portdest> _=> CnameD |-> PidD </portdest> ... </port> ...	</component>
	// sc.sp -> dp	
/*	rule <component> <comid>id|-> ComId:Identifier ... </comid><k> ConId:Identifier : Pt:PortType 
			CidS:Identifier . PidS:Identifier Dir:ConnectSymbol PidD:Identifier; => . ... </k>
			(. => <connection> <conid>id|->ConId type|-> Pt direction|->Dir </conid> <concom> 
			CidS|->CidD</concom> <conport> PidS|->PidD </conport></connection>) ... </component>
			<component> <subcomponent> id|->CidD:Identifier name|->ComId... </subcomponent> ... </component>
	// sp -> dc.dp	
	rule <component> <comid>id|-> ComId:Identifier ... </comid><k> ConId:Identifier : Pt:PortType 
			PidS:Identifier Dir:ConnectSymbol CidD:Identifier . PidD:Identifier; => . ... </k>
			(. => <connection> <conid>id|->ConId type|-> Pt direction|->Dir </conid> <concom> 
			CidS|->CidD</concom> <conport> PidS|->PidD </conport></connection>) ... </component>
			<component> <subcomponent> id|->CidS:Identifier name|->ComId... </subcomponent> ... </component>
	*/
	// subcomponent		
	rule <component><k>SubId:Identifier : ComCategory:ComponentCategory SubSystemId:Identifier Y:ComponentImplSuffix;
			=> . ... </k> (. => <subcomponent> id|->SubId name|-> SubSystemId type|->ComCategory 
			</subcomponent> ) ... </component>
	
	// property
	rule <component><k> Pk:PropertyKey Pa:PropertyAssign Pv:PropertyValue ; => . ...</k>
			<property> ... . => Pk |-> Pv </property>... </component>
	
	// behavior
	rule <component> <comid> id|->Comid:Identifier ... </comid> <k> annex behavior_specification {**
			Aslc:AnnexSpecificLanguageConstructs **} ; => Aslc ...</k>... </component>
			(. => <behavior> <componentid> Comid </componentid>	<states> .Map </states>
			<statevariables> .Map </statevariables>	<store> .Map </store>
			<automata> 
				<automataid> Comid </automataid>	<automataclock> 0 </automataclock>
				<status> kpending </status> <curstate> idles </curstate>	<eventcount> 0 </eventcount> 
				<processingevent> 0 |-> kclear </processingevent>	<event> .Map </event>
				<automatatable> .Map </automatatable> 		
			</automata></behavior>)
			<globalclock> 
				<subclockcount> (Tnum:Int => Tnum +Int 1) |-> 0 kclear|->_ </subclockcount>
				<subclock> ... . => Tnum |-> Comid </subclock> ...
			</globalclock>

	rule Bac1:AnnexSpecificLanguageConstructs Bac2:AnnexSpecificLanguageConstructs => Bac1 ~> Bac2 [structural]
	
	rule Bct:BehaviorClauseType Bc:BehaviorClause => Bc 		[structural]
	rule Bc1:BehaviorClause Bc2:BehaviorClause => Bc1 ~> Bc2 	[structural]
	// behavior state variables
	rule <component> <comid> id|->Comid:Identifier ... </comid> 
			<k> BVar:Identifier : Dbp:DataBehaviorPrefix Dt:DataType; => . ...</k>... </component>
			<behavior> <componentid> Comid </componentid>
			<statevariables> ... . => BVar|->Dt </statevariables> <store> ... . => BVar|->novalue </store>...</behavior> 		
	// behavior state
	rule <component> <comid> id|->Comid:Identifier ... </comid> 
			<k> Il:IdentifierList : Ss:TStates state ;=> . ...</k>... </component>
			<behavior> <componentid> Comid </componentid>	<states> ... .=>Il|->Ss </states>...</behavior> 		
	// behavior initial
	rule <component> <comid> id|->Comid:Identifier ... </comid> 
			<k> Variable:Expression := Value:Expression ;=> . ...</k>... </component>
			<behavior> <componentid> Comid </componentid>	<store> ... Variable|->(_=>Value) ...</store>...</behavior> 		
	// transitions
	rule <component> <comid> id|->Comid:Identifier ... </comid> 
			<k> CurState:Identifier -[ Ev:Event ]-> NextState:Identifier { Act:StatementList } ;
			=> . ...</k>... </component>
			<behavior> <componentid> Comid </componentid> 
			<automata>	<eventcount> EvSn:Int => (EvSn +Int 1) </eventcount>
				<event> ... . => EvSn |-> Ev </event>
				<automatatable> ... . => EvSn |-> (CurState, NextState, Act)...  </automatatable>...
			</automata> ...</behavior>
	
	// transitions, no event
	rule <component> <comid> id|->Comid:Identifier ... </comid> 
			<k> CurState:Identifier -[ ]-> NextState:Identifier { Act:StatementList } ;
			=> . ...</k>... </component>
			<behavior> <componentid> Comid </componentid> 
			<automata>	<eventcount> EvSn:Int => (EvSn +Int 1) </eventcount>
				<event> ... . => EvSn |-> true </event>
				<automatatable> ... . => EvSn |-> (CurState, NextState, Act)...  </automatatable>...
			</automata> ...</behavior>

		// 启动全局时钟。 条件：1、当初始component中的k cell中已经清空；2、且全局时钟为0。
	rule <component><k>. => run_globalclock</k><comid> .Map </comid>...</component> 
			<globalclock> <globaltime> Clock:Int </globaltime> 
			<subclockcount> Tc:Int |-> _ (kclear |-> Cc:Int => . )</subclockcount>...	</globalclock> 
			when (Clock =Int 0 andBool Tc >Int 0 andBool Tc =Int Cc)

	// advance global clock, prepare advance subclock: 
	// set subclockcount cell (Current clock) to total number subtract 1, it is sequence number of last clock
	rule <component><k>run_globalclock => run_subclock</k><comid> .Map </comid>...</component> 
		<globalclock> <globaltime> Clock:Int => Clock +Int 1 </globaltime>
		<subclockcount> Tc:Int |-> (_=>Tc -Int 1)</subclockcount>...</globalclock>
		
	// reentry subclock
	rule <component><k>reenter_clock => run_subclock</k><comid> .Map </comid>...</component> 
		<globalclock> <subclockcount> Tc:Int |-> (_=>Tc -Int 1)</subclockcount>...</globalclock>
		
	// advance sub clock. status: kidle to krunning
	rule <component><k> run_subclock </k><comid> .Map </comid>...</component> 
		<globalclock>	<subclockcount> _ |-> CurClock:Int </subclockcount> 
		<subclock> CurClock |-> Scid:Identifier ...</subclock> ...</globalclock>
			<automata> <automataid> Scid </automataid> <automataclock> Cv:Int => Cv +Int 1 </automataclock> 
			<eventcount> EvSn:Int </eventcount> <processingevent> (_ => EvSn -Int 1) |-> kclear </processingevent>
			<status> kidle => krunning </status>...
			</automata> // todo: 更改等待事件数量
	// end one sub clock advance, start next clock
	rule <globalclock>	<subclockcount> _ |-> (CurClock:Int => CurClock -Int 1) </subclockcount> 
		<subclock> CurClock |-> Scid:Identifier ...</subclock> ...</globalclock>
			<automata> <automataid> Scid </automataid>	<processingevent> EvSnP:Int |-> kclear </processingevent>
			<status> krunning => kidle </status>...	</automata> when (EvSnP <Int 0)

	// end sub clock advance, prepare global advance
/*	rule <component><k> run_subclock => run_globalclock </k><comid> .Map </comid>...</component>  
			<globalclock><subclockcount> _ |-> CurClock:Int </subclockcount> <globaltime> Clock:Int</globaltime>
			...</globalclock> when (CurClock <Int 0 andBool Clock <Int 6)*/
	// popup event
	rule <component> <comid>id|->Comid ...</comid><k>. => Ev </k> ... </component>
			<automata> <automataid>Comid:Identifier</automataid><processingevent> EvSn:Int |-> (kclear=>kpending) </processingevent>
			<status> krunning </status><event> EvSn|-> Ev:Event </event>... </automata> when (EvSn >=Int 0)

	// event not occur, advance processingevent cell for popup next event
	rule <component> <comid>id|->Comid ...</comid><k> false => . </k> ... </component>
			<automata> <automataid>Comid:Identifier</automataid>
			<processingevent> (EvSn:Int => EvSn -Int 1) |-> (kpending=>kclear) </processingevent>
			<status> krunning </status>... </automata> 
	// event occur, do active
	rule <component> <comid>id|->Comid ...</comid><k> true => Act </k> ... </component>
//			<component><k> _ => reenter_clock </k><comid> .Map </comid>...</component> 
			<automata> <automataid>Comid:Identifier</automataid>
			<status> krunning </status><processingevent> Cur:Int |-> (kpending=>krunning) </processingevent>
			<curstate> CurState => NextState </curstate><automatatable> 
			Cur|->(CurState:Identifier, NextState:Identifier, Act:StatementList) </automatatable>... </automata> 
	// event occur, active finished, reentry all automata
	rule <component> <comid>id|->Comid ...</comid><k> . </k> ... </component>
			<component><k> _ => reenter_clock </k><comid> .Map </comid>...</component> 
			<automata> <automataid>Comid:Identifier</automataid>
			<status> krunning => kidle </status><processingevent> Cur:Int |-> (krunning=>kclear) </processingevent>
			<curstate> CurState => NextState </curstate><automatatable> 
			Cur|->(CurState:Identifier, NextState:Identifier, Act:StatementList) </automatatable>... </automata> 

	// p?(e) , transfer to true or false
	rule <component> <comid> id|->Comid ...</comid><k> Portid:Identifier ?( Var:Expression) => true </k> 
			<port> <portid> id |-> Portid ... </portid> 
			<portitemcount> (Head:Int => Head +Int 1) |-> Tail:Int </portitemcount>
			<portdata> Head |-> Val:Identifier => . ...</portdata>... </port>... </component>
			<behavior> <componentid> Comid </componentid> <store> Var |-> (_ => Val) ...</store> ...</behavior>
			when (Head <Int Tail)

	rule <component> <comid> id|->Comid ...</comid><k> Portid:Identifier ?( Var:Expression) => false </k> 
			<port> <portid> id |-> Portid ... </portid>
			<portitemcount> Head:Int |-> Tail:Int </portitemcount>... </port>... </component>
			when (Head =Int Tail)
	
	// p!(e)
	rule <component> <comid> id|->Comid ...</comid><k> Portid:Identifier !( Var:Expression) => . </k> 
			<port> <portid> id |-> Portid ... </portid> <portdest> DComid:Identifier |-> DPortid:Identifier </portdest>	
			... </port>	... </component>
			<component> <comid> id|->DComid ...</comid> <port> <portid> id |-> DPortid ... </portid> <portdata> ... .=> Tail |-> Var </portdata>
			<portitemcount> _ |-> (Tail:Int => Tail +Int 1 ) </portitemcount> ... </port> </component>
	
	// Generate pseudocode
	// periodic thread
	rule <component> <k> . => 
		ThreadPrepare
		ThreadPrepareSync
		SetPeriodThreadStart
		while (GlobalTime < SimulationTime)
		{
			if (checkwaiting)
			{
				preemptcpu   // transition
			}
			if (checkmaybecontinue)
			{
				maybecontinue // transition
			}
			if (CheckThreadStart)
			{
				if (checkrunning || checkwaiting || checkmaybecontinue)
				{
					reporttimeout
					rememberstart
				} 
				else 
				{ 
					startperiodicthread  
				}
			}
			syncadvancetime
			checksyncgloballocalclock
			if (checkrunning)
			{
				run
				if (checkstop)
				{
					stop
				}
				else if (checkmaybestop)
				{
					maybestop //release CPU
				}
			}
			SyncPeriodicThreadReady
			CheckSyncPeriodicThreadReady
		}
		</k>
		<property> Dispatch_Protocol |-> periodic ... </property> ... </component>
		<component>// k cell in main component is empty;
			<comid> .Map </comid>
			<k> . </k> 
			... 
		</component> 
		<globalclock> <globaltime> 0 </globaltime> ... </globalclock>
		
	// aperiodic threads
	rule <component>
			<k> .=> 
				ThreadPrepare // count threads number, and class it
				ThreadPrepareSync
				SetRunTimes
				SetupAperiodicThread // create "LeftTimeToRestart"
				while (0 < TimesofRun)
				{
					SetupAperiodicThreadStart // set LeftTimeToRestart, set state to 4 (want to run)
					while (GlobalTime < SimulationTime && IsContinueRun)
					{
						if (checkwaiting)
						{
							preemptcpu   // transition
						}
						if (checkmaybecontinue)
						{
							maybecontinue // transition
						}
						
						if (CheckThreadStart)
						{
							if (checkrunning || checkwaiting)
							{
								rememberstart
							} 
							else 
							{ 
								StartAperiodicThread  // plus 1 to SchedulingThreads
							}
						}
						syncadvancetime
						checksyncgloballocalclock
						if (checkrunning)
						{
							run
							if (checkstop)
							{
								stop
							}
							else if (checkmaybestop)
							{
								maybestop //release CPU
							}
						}
						SyncAperiodicThreadReady
						CheckSyncAperiodicThreadReady
					}
					SetupAperiodicThreadTerminal // subtract 1 from SchedulingThreads
					SubtractRunTimes // TimesofRun subtract 1
				}
				AperiodicThreadFinish
			</k>
			<property> 
				Dispatch_Protocol |-> aperiodic 
				... 
			</property> 
			... 
		</component>
		<component>// k cell in main component is empty;
			<comid> .Map </comid>
			<k> . </k> 
			... 
		</component> 
		<globalclock> 
			<globaltime> 0 </globaltime> 
			... 
		</globalclock>

	// TestActive: only for test only
	rule <component>
			<k> TestActive => preemptcpu ...</k>
			<executions> .=> start |-> GTime ... </executions>
			<comstate> _ |-> (_=> PropertyVal) </comstate>
			<comclock> _=> GTime </comclock>
			<property> 
//				LeftTimeToRestart |-> (0 => 9) // 9 is no meaning, only the one large than 0
				Compute_Execution_Time |-> PropertyVal:PropertyValue
				... 
			</property> 
			...
		</component>
		<globalclock> 
			<globaltime> GTime:Int </globaltime> 
			... 
		</globalclock> 
               //   [transition]

		

	rule S1:SchedulingStatements S2:SchedulingStatements => S1 ~> S2
	// time unit change
	rule <property> Compute_Execution_Time |-> (Start:Int ms => Start to Start) ... </property>
	rule <property> Compute_Execution_Time |-> (Start:Int ms .. End:Int ms => Start to End) ... </property>
	rule <property> Period |-> (Val:Int ms => Val) ... </property>

////////////////////////////////pseudocode code ///////////////
	rule E1:Int < E2:Int => (E1 <Int E2)	[structural]
	rule true || _ => true					[structural]
	rule false || E:Exp => E				[structural]
	rule true && E:Exp => E					[structural]
	rule false && _ => false				[structural]
	rule ! true => false					[structural]
	rule ! false => true					[structural]
	rule while (E:Exp) { S:Stat } => if (E) {S while (E) {S} }   			[structural]
	rule if (true) {S:Stat} => S											[structural]
	rule if (false) {S:Stat} => .											[structural]
	rule if (true) {S1:Stat} else {S2:Stat} => S1							[structural]
	rule if (false) {S1:Stat} else {S2:Stat} => S2							[structural]
	rule if (true) {S1:Stat} else S2:Stat => S1								[structural]
	rule if (false) {S1:Stat} else S => S							[structural]
	
	rule S1:Stat S2:Stat => S1 ~> S2
	rule <k> GlobalTime => GTime ...</k> <globalclock><globaltime>GTime:Int</globaltime>...</globalclock>
	rule SimulationTime => 19
	
	// checkwaiting
	rule <component><k> checkwaiting => true ...</k><comstate> CState:Int |-> _</comstate> 
		... </component>  when CState =Int 2
	rule <component><k> checkwaiting => false ...</k><comstate> CState:Int |-> _</comstate> 
		... </component>  when CState =/=Int 2
		
	// checkrunning
	rule <component><k> checkrunning => true ...</k> <comstate> CState:Int |-> _</comstate>
		... </component>  when CState =Int 3
	rule <component><k> checkrunning => false ...</k><comstate> CState:Int |-> _</comstate> 
		... </component>  when CState =/=Int 3
		
	// checkmaybecontinue
	rule <component><k> checkmaybecontinue => true ...</k> <comstate> CState:Int |-> _</comstate>
		... </component>  when CState =Int 1
	rule <component><k> checkmaybecontinue => false ...</k><comstate> CState:Int |-> _</comstate> 
		... </component>  when CState =/=Int 1
	
	// IsContinueRun
	rule <component>
			<k> IsContinueRun => false ...</k> 
			<comstate> 0 |-> _</comstate>
			...
		</component>  
	rule <component>
			<k> IsContinueRun => true ...</k> 
			<comstate> CState:Int |-> _</comstate>
			...
		</component>  
		when CState >Int 0
	
	// SetupAperiodicThreadStart // set LeftTimeToRestart to 0
	rule <component>
			<k> SetupAperiodicThreadStart => . ...</k>
			<comstate> (_=>4) |-> _</comstate>
			<property> 
				LeftTimeToRestart |-> (_=>0)
				... 
			</property> 
			... 
		</component>

	// SetupAperiodicThreadTerminal
	rule <component>
			<k> SetupAperiodicThreadTerminal => . ...</k>
			<property> 
				LeftTimeToRestart |-> (_=>0)
				... 
			</property> 
			... 
		</component>
		<cpu>
			<threads>
				SchedulingThreads |-> (STh:Int => STh -Int 1)
				...
			</threads>
			...
		</cpu>
		
	// StartAperiodicThread: running threads plus 1; 
	rule <component>
			<k> StartAperiodicThread => preemptcpu ...</k>
			<executions> .=> start |-> GTime ... </executions>
			<comstate> _ |-> (_=> PropertyVal) </comstate>
			<comclock> _=> GTime </comclock>
			<property> 
				LeftTimeToRestart |-> (0 => 9) // 9 is no meaning, only the one large than 0
				Compute_Execution_Time |-> PropertyVal:PropertyValue
				... 
			</property> 
			...
		</component>
		<globalclock> 
			<globaltime> GTime:Int </globaltime> 
			... 
		</globalclock> 
		<cpu> 
			<threads>
				SchedulingThreads |-> (STh:Int => STh +Int 1)
				...
			</threads>
			...
		</cpu>                          [transition]
	
	// CheckThreadStart
	rule <component>
			<k> CheckThreadStart => true ...</k>
			<property> 
				LeftTimeToRestart |-> 0
				... 
			</property> 
			... 
		</component>
	rule <component>
			<k> CheckThreadStart => false ...</k>
			<property> 
				LeftTimeToRestart |-> LeftTime:Int   
				... 
			</property>
			...
		</component> 
		when (LeftTime =/=Int 0)
	
	// SetRunTimes
	rule <component>
			<k> SetRunTimes => . ...</k>
			<comid> 
				ScheduledTimes |-> ( _=> 1)
				...
			</comid>
			...
		</component> 
	
	// TimesofRun
	rule <component>
			<k> TimesofRun => I ...</k>
			<comid> 
				ScheduledTimes |-> I:Int
				...
			</comid>
			...
		</component> 
	
	// SubtractRunTimes
	rule <component>
			<k> SubtractRunTimes => . ...</k>
			<comid> 
				ScheduledTimes |-> (I:Int => I -Int 1)
				...
			</comid>
			...
		</component> 
	
	// checkstop
	rule <component>
			<k> checkstop => true ...</k>
			<comstate> 3 |-> 0 to 0
			</comstate>
			... 
		</component>
	rule <component>
			<k> checkstop => false ...</k>
			<comstate> 3 |-> _ to LeftTimeR:Int
			</comstate>
			... 
		</component>
		when (LeftTimeR >Int 0)
		
	// checkmaybestop
	rule <component>
			<k> checkmaybestop => true ...</k>
			<comstate> 3 |-> 0 to _
			</comstate>
			... 
		</component>
	rule <component>
			<k> checkmaybestop => false ...</k>
			<comstate> 3 |-> LeftTimeL:Int to _
			</comstate>
			... 
		</component>
		when (LeftTimeL >Int 0)
	
	// SetPeriodThreadStart: set LeftTimeToRestart to 0
	rule <component>
			<k> SetPeriodThreadStart => . ...</k>
			<property> 
				(. => LeftTimeToRestart |-> 0)
				... 
			</property> 
			...
		</component>
	
	// SetupAperiodicThread
	rule <component>
			<k> SetupAperiodicThread => . ...</k>
			<property> 
				(. => LeftTimeToRestart |-> 0)
				... 
			</property> 
			...
		</component>
	
	// startperiodicthread: start thread when thread idle
	rule <component>
			<k> startperiodicthread => preemptcpu ...</k>
			<executions> .=> start |-> GTime ... </executions>
			<comstate> _ |-> (_=> PropertyVal) </comstate>
			<property> 
				LeftTimeToRestart |-> (0 => PeriodTime)
				Period |-> PeriodTime:Int
				Compute_Execution_Time |-> PropertyVal:PropertyValue
				... 
			</property> 
			...
		</component>
		<globalclock> 
			<globaltime> GTime:Int </globaltime> 
			... 
		</globalclock> 
		
	// preempt cup
	// preempt from idle cpu
	rule <component>
			<k> preemptcpu => . ...</k>
			<property> Priority |-> CurrentThPriority:Int ... </property>	
			<comstate> (_ => 3) |-> _ </comstate>
			<comid> id |-> Cid:Identifier ... </comid> 		
			... 
		</component>
		<cpu> 
			<state> 0|->0 => Cid|-> CurrentThPriority </state> 
			...
		</cpu>  														[transition]
	// preempt from running cpu
	// success, change state to running
	rule <component>
			<k> preemptcpu => . ...</k>
			<property> Priority |-> CurrentThPriority:Int ... </property>	
			<comstate> (_ => 3) |-> _ </comstate>
			<comid> id |-> Cid:Identifier ... </comid> 		
			... 
		</component>
		<component> 
			<comstate> (3 => 2) |-> _ </comstate> 
			<comid> id |-> RunningThId:Identifier ... </comid> 		
			... 
		</component>
		<cpu> 
			<state> RunningThId |-> RunningThPriority:Int => Cid|-> CurrentThPriority </state> 
			... 
		</cpu>
		when (CurrentThPriority >Int RunningThPriority )  				[transition]
	// preempt cpu fail
	// change state to waiting
	rule <component>
			<k> preemptcpu => . ...</k>
			<property> Priority |-> CurrentThPriority:Int ... </property>	
			<comstate> (_ => 2) |-> _ </comstate>
			<comid> id |-> Cid:Identifier ... </comid> 
			... 
		</component>
		<cpu> 
			<state> _ |-> RunningThPriority:Int </state> 
			... 
		</cpu>
		when (CurrentThPriority <=Int RunningThPriority ) 				[transition]
	
	// syncadvancetime: advance local clock, adjust ready threads
	rule <component> 
			<k> syncadvancetime => . ... </k>
			<comclock> CTime:Int => CTime +Int 1 </comclock>  
			... 
		</component>
		<cpu> 
			<threads> 
				ReadyThreads |-> (I:Int => I +Int 1) 
				...
			</threads> 
			... 
		</cpu>
	
	// checksyncgloballocalclock: block for sync, continue when global clock advanced
	rule <component> 
			<k> checksyncgloballocalclock => . ... </k> 
			<comclock> CTime:Int </comclock>     
			...
		</component>
		<globalclock> 
			<globaltime> GTime:Int </globaltime> 
			... 
		</globalclock> 
		when (GTime =Int CTime)
	
	// advance global clock
	rule <globalclock> 
			<globaltime> GTime:Int => GTime +Int 1 </globaltime> 
			... 
		</globalclock> 
		<cpu> 
			<threads> 
				SchedulingThreads |-> ATh:Int 
				ReadyThreads |-> (RTh:Int => 0) 
				...
			</threads> 
			... 
		</cpu>
		when (ATh =Int RTh andBool ATh >Int 0)								[transition]
	
	// run: // count running time for "previous unit".
	rule <component>
			<k> run => . ...</k>
			<property> Priority |-> CurrentThPriority:Int ... </property>	
			<comstate> 3 |-> (LeftTimeL:Int => LeftTimeL -Int 1) to (LeftTimeR:Int => LeftTimeR -Int 1)
			</comstate>
			... 
		</component>
		when (LeftTimeL >Int 0)
	rule <component>
			<k> run => . ...</k>
			<property> Priority |-> CurrentThPriority:Int ... </property>	
			<comstate> 3 |-> 0 to (LeftTimeR:Int => LeftTimeR -Int 1)
			</comstate>
			... 
		</component>
		
	// SyncPeriodicThreadReady: sync ready thread and subtract 1 of LeftTimeToRestart
	rule <component>
			<k> SyncPeriodicThreadReady => . ...</k>
			<property> 
				LeftTimeToRestart |-> (LeftTime:Int => LeftTime -Int 1) 
				... 
			</property>	
			...
		</component>
		<cpu> 
			<threads> 
				SyncThreads |-> (SyncThNum:Int => SyncThNum +Int 1) 
				...
			</threads> 
			... 
		</cpu>
	
	//CheckSyncPeriodicThreadReady
	rule <component>
			<k> CheckSyncPeriodicThreadReady => . ...</k>
			...
		</component>
		<cpu> 
			<threads> SyncThreads |-> 0 ... </threads> 
			... 
		</cpu>
	
	// SyncAperiodicThreadReady
	rule <component>
			<k> SyncAperiodicThreadReady => . ...</k>
			...
		</component>
		<cpu> 
			<threads> 
				SyncThreads |-> (SyncThNum:Int => SyncThNum +Int 1) 
				...
			</threads> 
			... 
		</cpu>
	
	//CheckSyncAperiodicThreadReady
	rule <component>
			<k> CheckSyncAperiodicThreadReady => . ...</k>
			...
		</component>
		<cpu> 
			<threads> SyncThreads |-> 0 ... </threads> 
			... 
		</cpu>
	
	// to sync ready thread 
	rule <cpu> 
			<threads> 
				SchedulingThreads |-> SyncThNum
				SyncThreads |-> (SyncThNum:Int => 0) 
				...
			</threads> 
			... 
		</cpu>
		when (SyncThNum >Int 0)
	
	// stop: release CPU
	rule <component>
			<k> stop => . ...</k>
			<executions> .=> terminal |-> GTime ... </executions>
			<comstate> (3 => 0) |-> _ </comstate>
			<comid> id |-> Cid:Identifier ... </comid> 		
			...
		</component>
		<cpu>
			<state> Cid|-> _ => 0 |-> 0  </state> 
			...
		</cpu>
		<globalclock> 
			<globaltime> GTime:Int </globaltime> 
			... 
		</globalclock> 

	
	// maybestop: release CPU
	rule <component>
			<k> maybestop => . ...</k>
			<comstate> (3 => 1) |-> _ </comstate>
			<comid> id |-> Cid:Identifier ... </comid> 		
			... 
		</component>
		<cpu> 
			<state> Cid|-> _ => 0 |-> 0  </state>
			...
		</cpu>
	
	// maybecontinue: continue in maybestop state if CPU idle
	// continue to run
	rule <component>
			<k> maybecontinue => . ...</k>
			<property> Priority |-> CurrentThPriority:Int ... </property>	
			<comstate> (1=>3) |-> _ </comstate>
			<comid> id |-> Cid:Identifier ... </comid> 		
			... 
		</component>
		<cpu> 
			<state>  0 |-> 0 => Cid|-> CurrentThPriority </state>
			...
		</cpu>							 						[transition]
	// maybecontinue fail, stop run
	rule <component>
			<k> maybecontinue => . ...</k>
			<executions> .=> terminal |-> GTime ... </executions>
			<comstate> 1 |-> _ => 0 |-> 0 to 0 </comstate>
			... 
		</component>
		<cpu> 
			<state>  _ |-> RunningThPriority:Int </state>
			...
		</cpu>
		<globalclock> 
			<globaltime> GTime:Int </globaltime> 
			... 
		</globalclock> 
		when (RunningThPriority >Int 0)	 						[transition]

	// reporttimeout
	rule <component>
			<k> reporttimeout => . ...</k>
			<comid> id |-> Cid:Identifier ... </comid>
			<comstate> CState:Int |-> _ </comstate> 
			... 
		</component>
		<globalclock> 
			<globaltime> GTime:Int </globaltime> 
			... 
		</globalclock> 
		<warnning>  
			<timeout> .=> Cid |-> GTime, CState ...</timeout>  // thread id |-> (Global time, state)
		</warnning>
	
	// rememberstart
	rule <component>
			<k> rememberstart => . ...</k>
			<comid> ScheduledTimes |-> (SchTimes:Int => SchTimes +Int 1) ... </comid>
			<property> 
				LeftTimeToRestart |-> (_ => PTime) // count down once more
				Period |-> PTime:Int
				...
			</property>
			... 
		</component>
		
	// ThreadPrepare
	// periodic threads
	rule <component>
			<k> ThreadPrepare => . ...</k>
			<property> 
				Dispatch_Protocol |-> periodic
				...
			</property>
			... 
		</component>
		<cpu> 
			<threads>  
				PeriodicThreads |-> (PTh:Int => PTh +Int 1)
				SchedulingThreads |-> (STh:Int => STh +Int 1)
				...
			</threads>  
			...
		</cpu>	
	// aperiodic threads
	rule <component>
			<k> ThreadPrepare => . ...</k>
			<property> 
				Dispatch_Protocol |-> aperiodic
				...
			</property>
			... 
		</component>
		<cpu> 
			<threads>  
				AperiodicThreads |-> (AperiodicTh:Int => AperiodicTh +Int 1)
				...
			</threads>  
			...
		</cpu>	
//		when (ATh =/=Int 3)
		
	// aperiodic threads
	rule <component>
			<k> ThreadPrepare => . ...</k>
			<property> 
				Dispatch_Protocol |-> sporadic
				...
			</property>
			... 
		</component>
		<cpu> 
			<threads>  
				SporadicThreads |-> (STh:Int => STh +Int 1)
				...
			</threads>  
			...
		</cpu>	
	
	// ThreadPrepareSync
	rule <component>
			<k> ThreadPrepareSync => . ...</k>
			... 
		</component>
		<cpu> 
			<threads>  
				AperiodicThreads |-> ATh:Int
				PeriodicThreads |-> PTh:Int
				SporadicThreads |-> STh:Int
				TotalThreads |-> TTh:Int
				...
			</threads>  
			...
		</cpu>
		when (TTh =Int (ATh +Int PTh +Int STh) )
		
///////////////////////////end of pseudocode code /////////////

endmodule
