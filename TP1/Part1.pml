byte tour;byte ncritical;
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
	  ::(tour == 0 && !enPanneECS) -> ncritical++; critiqueECS = true; atomic{canal_M_1!ECS,1}; critiqueECS = false; ncritical--; tour = 1;
	  ::(tour == 1 && !enPanneFCS) ->ncritical++; critiqueFCS = true; atomic{canal_M_1!FCS,2}; critiqueFCS = false; ncritical--; tour = 0;
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