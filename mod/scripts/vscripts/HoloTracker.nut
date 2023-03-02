global function HoloTrackerInit
global function ActivateDecoyTracking
global function StopDecoyTracking

const float MAX_HOLOPILOT_DURATION = 10.0

void function HoloTrackerInit(){
	RegisterSignal( "EndDecoyTracking" )
	AddServerToClientStringCommandCallback( "ActivateDecoyTracking", ActivateDecoyTracking )
	AddServerToClientStringCommandCallback( "StopDecoyTracking", StopDecoyTracking )
}

void function ActivateDecoyTracking(array <string> args){
	/*
	//Logger.Info("Command received from server!")
	foreach(arg in args)
	{
		//Logger.Info(arg)
	}
	
	entity player = GetEntityFromEncodedEHandle( args[1].tointeger() )
	
	if(player != null)
		//Logger.Info(player.GetPlayerName())
		
	entity decoy = GetEntityFromEncodedEHandle( args[0].tointeger() )
	
	if(decoy == null)
		//Logger.Info("Damn it")
	*/
	//Actual thing:
	if(args.len() > 0){
		//Logger.Info("Starting thread...")
		thread DecoyTrackingThread(args[0].tointeger())
		
	}
}

void function StopDecoyTracking(array <string> args){
	if(args.len() > 0){
		entity decoy = GetEntityFromEncodedEHandle( args[0].tointeger())
		if(decoy != null)
			decoy.Signal("EndDecoyTracking")
	}
}

void function DecoyTrackingThread(int eHandle){
	//Logger.Info("Thread began")
	Wait(0.1) //Needed for the eHandle to work
	entity decoy = GetEntityFromEncodedEHandle( eHandle )
	if(decoy != null && IsValid(decoy))
	{
		//Logger.Info("Decoy detected!")
		decoy.EndSignal( "OnDeath" )
		decoy.EndSignal( "OnDestroy" )
		decoy.EndSignal( "EndDecoyTracking" )
	
		var rui = CreateCockpitRui( $"ui/overhead_icon_evac.rpak", MINIMAP_Z_BASE + 200  ) //, MINIMAP_Z_BASE + 200 
		//var rui = CreateCockpitRui( $"ui/overhead_icon_generic.rpak", MINIMAP_Z_BASE + 200 )
		RuiSetImage( rui, "icon", $"rui/menu/boosts/boost_icon_holopilot" )
		RuiSetBool( rui, "isVisible", true )
		RuiTrackFloat3( rui, "pos", decoy, RUI_TRACK_OVERHEAD_FOLLOW)
		RuiSetString( rui, "statusText", "#HOLOTRACKER_TIME_REMAINING" )
		RuiSetGameTime( rui, "finishTime", Time()+MAX_HOLOPILOT_DURATION )
		
		OnThreadEnd(
			function() : ( decoy, rui )
			{
				if(rui != null)
					RuiDestroy(rui)
				//Logger.Info("Thread ended in IF")
			}
		)
	}
	float threadEndTime = Time() + MAX_HOLOPILOT_DURATION
	for(;;){
		WaitFrame()
		if(Time() > threadEndTime) //This one is to remove the tracker after holopilot begins to dissolve
			break
	}
	//Logger.Info("Thread ended")
}