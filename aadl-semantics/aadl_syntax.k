
module AADL-SYNTAX

	syntax Identifier ::= Token{[A-Za-z\_][A-Za-z\_0-9]*}    [onlyLabel]
	                | Token{"main"}
					| "test"
					| "string" | "noname" | "novalue"
					| "NotInitialized"
					| "setupcom" | "run_globalclock" | "run_subclock" | "reenter_clock"
					| "kidle" | "krunning" | "kpending" | "kclear"
					| "category" | "id" | "name"
					| "type" | "direction" | "datatype"
					| "idles"
					| "idle" | "busy" | "running" 
					| "wait" | "preempt" | "sync"
					| "terminal"
					| "ScheduledTimes"
					| "SyncThreads"
					| "ReadyThreads"
					| "SchedulingThreads"
					| "PeriodicThreads"
					| "AperiodicThreads"
					| "SporadicThreads"
					| "TotalThreads"

					
	syntax IdentifierList ::= List{Identifier, ","}
	syntax TripleUnit ::= Identifier ";" Identifier ";" Identifier
	
	
	syntax K  ::= "TimeAutomata"

//	AADL_specification ::= AADL_global_declaration 
//					| AADLDeclaration

//	AADL_global_declaration ::= package_spec
//							| Property_set
	syntax AADLDeclaration ::= ComponentClassifier
//					| port_group_classifier 
//					| annex_library
	syntax ComponentClassifier ::= ComponentClassifier ComponentClassifier  [left]
						| ComponentCategory Identifier 
						| ComponentCategory Identifier 
							ComponentType 
							"end" Identifier ";"
						| ComponentCategory Identifier 
							"end" Identifier ";"
						| ComponentCategory Identifier 
							ComponentType 
							
						| ComponentCategory "implementation" ComponentImplIdentifier 
							ComponentType 
						  "end" ComponentImplIdentifier ";"
						| ComponentCategory "implementation" Identifier 
						| ComponentCategory "implementation" Identifier 
							ComponentType 
						| ComponentCategory "implementation" ComponentImplIdentifier 
						  "end" ComponentImplIdentifier ";"
//						| ComponentType_extension 
//						| component_implementation 
//						| component_implementation_extension 
//	port_group_classifier ::= port_group_type 
//						| port_group_type_extension 
	syntax ComponentImplSuffix ::= ".impl"
	syntax ComponentImplIdentifier ::= Identifier ComponentImplSuffix
	syntax ComponentCategory ::= "system" | "process" | "thread"
	syntax ComponentType ::= ComponentType ComponentType [left]
					| ClauseType Clause
					| AnnexSubclause

	syntax Property ::= PropertyKey PropertyAssign PropertyValue ";"
	syntax PropertyAssign ::= "=>"
	syntax PropertyUnit ::= "sec"
						| "ms"
	syntax PropertyValue ::= "periodic"
			| Int PropertyUnit
			| Int PropertyUnit ".." Int PropertyUnit   // range
			| "aperiodic"
			| "sporadic"
			| Int
			| Int ";" Int ";" Int 
			| Int "to" Int
	syntax PropertyKey ::= "Dispatch_Protocol"
			| "Compute_Execution_Time"
			| "Period"
			| "Priority"
			| "Assist"
			| "LeftTimeToRestart"  // Left time to restart in Periodic thread
	
	syntax Connection  ::=  PortConnection
	//					| Connection Connection [left]
	syntax PortConnection ::= Identifier ":" PortType Reference ConnectSymbol Reference ";"
	
	syntax Subcomponents ::= "subcomponents" SubcomList
							| "subcomponents"
	syntax SubcomList ::= List{Subcomponent, ""}
	syntax Subcomponent ::= Identifier ":" ComponentCategory ComponentImplIdentifier ";"
				
	syntax ClauseType ::= "features" | "connections" | "subcomponents" | "properties"
	syntax Clause ::= Clause Clause [left]
					| Feature
					| Connection
					| Subcomponent
					| Property
//					| flows

	syntax Feature ::= PortSpec
//					| Feature Feature [left]
	
	syntax PortSpec ::= Identifier ":" PortDirection PortType DataClassifier ";"

	syntax PortDirection ::= "in" | "out" | "in" "out"
	syntax PortType ::= "data" "port"
			| "event" "data" "port"
			| "event" "port"
			
	syntax DataType ::= "integer" | "boolean" | "float"
	syntax DataClassifier ::=  DataBehaviorPrefix DataType
	syntax DataBehaviorPrefix ::= "Behavior::"
	syntax Reference ::= Identifier "." Identifier
			| Identifier
	syntax ConnectSymbol ::= DirectionalConnectionSymbol 
				| BidirectionalConnectionSymbol
	syntax DirectionalConnectionSymbol ::= "->"
	syntax BidirectionalConnectionSymbol ::= "<->"
	
	syntax AnnexSubclause ::= "annex" AnnexIdentifier "{**"
								AnnexSpecificLanguageConstructs
							"**}" ";"
							| "annex" AnnexIdentifier AnnexSpecificLanguageConstructs
	syntax AnnexIdentifier ::= "behavior_specification"
	
	syntax AnnexSpecificLanguageConstructs ::= AnnexSpecificLanguageConstructs 
									AnnexSpecificLanguageConstructs [left]
								| BehaviorClauseType BehaviorClause
	syntax BehaviorClauseType ::= "state" "variables"
									| "states"
									| "initial"
									| "transitions"
	syntax BehaviorClause ::= BehaviorClause BehaviorClause [left]
							| BVariable
							| State
							| Assignment // initial
							| Transition
	syntax BVariable ::= Identifier ":" DataClassifier ";"
	syntax Assignment ::= Expression AssignmentSymb Expression ";"
	syntax AssignmentSymb ::= ":="
	
	syntax State ::= IdentifierList ":" TStates "state" ";"
	syntax TStates ::= List{TState, ""}
	syntax TState ::= "initial"
			| "complete"
			| "return"
			| "urgent"
			| "composite"
			| "exit"
				
	syntax Transition ::= Identifier "-[" Event "]->" Identifier "{" StatementList "}" ";"
				| Identifier "-[" "]->" Identifier "{" StatementList "}" ";"
	syntax Event ::= Identifier "!""(" Expression ")"
			| Identifier "?""(" Expression ")"
			| Identifier "?"
			| Identifier 
			| "on" Expression
			| Event "when" Expression
			| "computation" "(" PropertyValue ")"
	syntax Eventtype ::= "dport" | "eport" | "time"
	syntax Expression ::= Identifier
						| Int
						| Expression "=" Expression
	syntax Statement ::= Event ";"
			| Expression ";"
	syntax StatementList ::= List{Statement, ""}
	
	syntax EventItem ::= "(" Eventtype "," Identifier "," Identifier ")" // p?(i)
						| "(" Eventtype "," Identifier "," Identifier "," Expression ")" 
	syntax AutomataTableItem ::= "(" Identifier "," Identifier "," StatementList ")"

	syntax PortCell ::= Identifier ";" PortType ";" PortDirection ";" DataType
						| Identifier ";" Identifier

	syntax SchedulingStatements ::= SchedulingStatements SchedulingStatements [left]
					| "ThreadStart" "(" Int ")"";"
					| "ThreadRun" "(" Int ")"";"
					| "periodic" "(" Int ")"
	syntax Expression ::= Expression Expression [left]
					| "start" | "preempt" | "wait" | "sync"
					| "not" Expression
					| "success"
					| "if""(" Expression ")" "{" Expression "}"  [strict(1)]

	syntax Warnning ::= Int "," Int
	
/////// pseudocode syntax ///////////
	syntax Exp ::= Bool | Int
				| Exp "<" Exp   				[left, strict]
				| "!" Exp						[strict]
				> Exp "||" Exp					[left, strict(1)]
				| Exp "&&" Exp					[left, strict(1)]
				| "checkwaiting" | "checkrunning" | "checkstop" | "checkmaybestop"
				| "CheckThreadStart"
				| "checkmaybecontinue" // Is it in maybestop state
				| "GlobalTime" | "SimulationTime" | "TimesofRun" | "IsContinueRun"
	syntax Stat ::= Stat Stat    											[left]
				| "preemptcpu" | "reporttimeout" | "rememberstart" | "syncadvancetime" 
				| "checksyncgloballocalclock" | "isrunning" | "iswaiting" | "run" | "stop" 
				| "maybestop" | "SyncPeriodicThreadReady" | "SetPeriodThreadStart"
				| "startperiodicthread" | "CheckSyncPeriodicThreadReady" | "maybecontinue" 
				| "Debug" "(" Int ")" | "TestActive"
				| "StartAperiodicThread" | "SetupAperiodicThreadTerminal"
				| "SetupAperiodicThread" | "SetupAperiodicThreadStart"
				| "ThreadPrepare" | "ThreadPrepareSync"
				| "SetRunTimes" | "SubtractRunTimes"
				| "SyncAperiodicThreadReady" | "CheckSyncAperiodicThreadReady"
				| "AperiodicThreadFinish"
				| "while" "(" Exp ")" "{" Stat "}"										[strict(1)]
				| "if" "(" Exp ")" "{" Stat "}"											[strict(1)]
				| "if" "(" Exp ")" "{" Stat "}" "else" "{" Stat"}"						[strict(1)]
				| "if" "(" Exp ")" "{" Stat "}" "else" Stat								[strict(1)]
/////// end of pseudocode ////
endmodule
