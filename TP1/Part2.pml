
byte tour = 0;
byte nmsgcritical = 0;
byte nmsgrecu = 0;
byte nmsgenvoi = 0;
mtype = {ECS, FCS, LGS};

chan canal_ECS = [10] of {mtype, byte};
chan canal_FCS = [5] of {mtype, byte};
chan canal_LGS = [3] of {mtype, byte};
chan canal_MDS = [10] of {mtype, byte};


active proctype M_1()
{	
	do
	:: if
	   :: (tour == 0) -> canal_ECS!ECS,1; tour = 1; nmsgenvoi++;
	   :: else -> canal_FCS!FCS,2; tour = 0; nmsgcritical++; nmsgenvoi++;
	   fi
	od
}

active proctype M_2()
{	
	do
	:: canal_LGS!LGS,3; nmsgcritical++; nmsgenvoi++;
	od
}

active proctype CC()
{	
	mtype msg;
	byte receive;
	do
	::  
		if
		::(nempty(canal_ECS) && nfull(canal_MDS)) -> canal_ECS?msg(receive); canal_MDS!msg,receive; nmsgrecu++;
		:: else -> skip
		fi
		
		if
		::(nempty(canal_FCS) && nfull(canal_MDS)) -> canal_FCS?msg(receive); canal_MDS!msg,receive; nmsgcritical--; nmsgrecu++;
		:: else -> skip
		fi
		
		if
		::(nempty(canal_LGS) && nfull(canal_MDS)) -> canal_LGS?msg(receive); canal_MDS!msg,receive; nmsgcritical--; nmsgrecu++;
		:: else -> skip
		fi
		
		if
		::timeout -> break;
		fi
		od
}



ltl p0 {[](nmsgenvoi > nmsgrecu)} /*Liveness*/
ltl p1 {[]((nmsgcritical > 0) -> <>(nmsgcritical == 0)) } /*safety*/