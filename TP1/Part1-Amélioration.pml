byte tour = 0;byte ncritical = 0;
bool enPanneECS = false, enPanneFCS = false;
bool critiqueECS = false, critiqueFCS = true;

mtype = {FCS, ECS};
chan canal_M_1 = [0] of {mtype, byte};

active proctype M_1(){
	do
	::(enPanneECS && enPanneFCS) -> break;
	::enPanneFCS = true;
	::enPanneECS = true;
	::if
	  ::((tour == 0 && !enPanneECS) || (tour != 0 && !enPanneECS && enPanneFCS)) -> ncritical++; atomic{canal_M_1!ECS,1}; ncritical--; tour = 1;
	  ::((tour == 1 && !enPanneFCS) || (tour == 1 && !enPanneFCS && enPanneECS)) ->ncritical++; atomic{canal_M_1!FCS,2}; ncritical--; tour = 0;
	  ::else -> skip;
	  fi
	od
	end:
		do
		::skip
		od
}

active proctype pbidon (){
	byte read;
	mtype bdon;
    do
	:: canal_M_1?bdon(read);
    od
}

ltl p0 {[](ncritical <= 1) } /*Safety*/
ltl p1 {[]( (!enPanneECS -> <>(critiqueECS || enPanneECS)) && (!enPanneFCS -> <>(critiqueFCS || enPanneFCS))  )} /*Liveness*/
ltl p2 {[]( ( enPanneFCS -> (!enPanneECS -> <>(critiqueECS || enPanneECS))) && (enPanneECS -> (!enPanneFCS -> <>(critiqueFCS || enPanneFCS))))} /*Liveness*/