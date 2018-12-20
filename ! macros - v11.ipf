#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma TextEncoding = "MacRoman"
macro dectaumac()
	dectau()
endmacro

function dectau()
	string wl=tracenamelist("",";",1)
	string wn=stringfromlist(0,wl)
	variable i=0,n=itemsinlist(wl), xs = xcsr(A), xe = xcsr(B)
	make/O/N=(3) W_coef
	make/O/N=(n) results
	do 
		wn=removequotes( stringfromlist(i,wl) )
		WAVE w = $wn
		CurveFit/Q/TBOX=256 exp w(xs, xe) /D 
		print wn, 1000/w_coef[2]
		results[i] = 1000/w_coef[2]
		i += 1
	while( i < n )
end

//\\//\\//\\//\\//\\//\\//\\//\\

macro eventAnalysis( peaksign )
variable peaksign = -1	// sets optional parameter to determine sign of peak, +1 for positive, -1 for negative peak

// required parameters
variable m_rin = 0 		// disable input resistance measurement, only works for current clamp :: DO NOT SET TO 1 ::
variable use_csr = 0	 	// :: -1 use x-axis for range, :: 0 use default range -inf, inf sec, :: 1 use cursors A and B for range

// optional parameters in function call
variable trace 				// set tr = trace if you want to specify which trace, only use if multiple traces
variable baseline			// set bsl = baseline if you want to specify when the baseline measurement starts (5 msec dur)
variable xstart = -0.001, xend = inf				// set xs = xstart, xe = xend to specify a manual range for peak detection and analysis
variable peakwin = 0.01			// set pwin = peakwin, this sets the window to search for the peak if multiple peaks, starts at xstart 

print eventM( m_rin, use_csr, xs = xstart, xe = xend, pwin = peakwin, psign = peaksign )

endmacro

//\\//\\//\\//\\//\\//\\//\\//\\
// td version for averaged AMPA PSCs from blast_panel detection
//

macro AMPA_avePSCs( peaksign )
variable peaksign = -1	// sets optional parameter to determine sign of peak, +1 for positive, -1 for negative peak

// required parameters
variable m_rin = 0 		// disable input resistance measurement, only works for current clamp :: DO NOT SET TO 1 ::
variable use_csr = 0	 	// :: -1 use x-axis for range, :: 0 use default range -inf, inf sec, :: 1 use cursors A and B for range

// optional parameters in function call
variable trace 				// set tr = trace if you want to specify which trace, only use if multiple traces
variable baseline = -0.01			// set bsl = baseline if you want to specify when the baseline is taken
variable xstart = -0.002, xend = inf				// set xs = xstart, xe = xend to specify a manual range for peak detection and analysis
variable peakwin = 0.01			// set pwin = peakwin, this sets the window to search for the peak if multiple peaks, starts at xstart 

print eventM( m_rin, use_csr, bsl = baseline, xs = xstart, xe = xend, pwin = peakwin, psign = peaksign )

endmacro

//
// td version for dcPSP analysis
//
//  \\//\\//\\//\\//\\//\\//\\//\\
//\\//\\//\\//\\//\\//\\//\\//\\

macro test_smartPeak()
variable peaksign = -1			// sets optional parameter to determine sign of peak, +1 for positive, -1 for negative peak

	// required parameters
	variable m_rin = 1 			// disable input resistance measurement, only works for current clamp :: DO NOT SET TO 1 unless you are pro ::
	variable use_csr = 0	 		// :: -1 use x-axis for range, :: 0 use default range -inf, inf sec, :: 1 use cursors A and B for range
	
	// optional parameters in function call
	variable trace 					// set tr = trace if you want to specify which trace, only use if multiple traces
	variable baseline	= 0.25	// set bsl = baseline if you want to specify when the baseline is taken
	
	variable xstart = 0.15
	variable xend = 0.35			// set xs = xstart, xe = xend to specify a manual range for peak detection and analysis
	variable xinc = 0.0
	
	variable peakwin = 0.015		// set pwin = peakwin, this sets the window to search for the peak if multiple peaks, starts at xstart 
	string nm = "first_", holder=""
	string wlist = winlist("*", ";", ""), panelwin = stringfromlist( 0, wlist )
	string tablen = "smartPeak"
	variable imax = 11
	variable nsmooth = 11
	
	string pathn = "collector_data", passwn = "", passTablen="", targetwn = "", expcode = ""

	targetwn = removequotes( stringfromlist( 0, tracenamelist( "", ";", 1 ) ) )
	expcode = removequotes( datecodefromanything( targetwn ) )
	passTablen = "T_" + expcode + "_0"
	
	string wl = tracenamelist( "", ";", 1 ),outwn

	//function/S smartPeak( wl, tstart, tend, nsmth, suffix, [do_avg, do_tau, order, posneg ] )
	holder = smartpeak( wl, xstart, xend, nsmooth, "spx" )
	outwn = stringbykey( "peak", holder )
	dowindow/F peaktable0
	if(V_Flag == 0 ) // notable
		edit/k=1/N=peaktable0 $outwn
	else
		appendtotable $outwn
	endif

	holder = smartpeak( wl, xend-0.01, xend, nsmooth, "sps" )
	outwn = stringbykey( "peak", holder )
	dowindow/F sustable0
	if(V_Flag == 0 ) // notable
		edit/k=1/N=sustable0 $outwn
	else
		appendtotable $outwn
	endif


	dowindow/F $panelwin

	passwn = passiveSandwich( setpathn = pathn, passiveTablen = passTablen, targetwn = targetwn ) // acts on top window!
	
	dowindow/F $tablen
	//WAVE/Z pw = $passwn
	//if( waveexists( pw ) )
	if( waveexists( $passwn ) )
		appendtotable/W=$tablen $passwn
	endif
	equilibrateTable()

endmacro
//\\//\\//\\//\\//\\//\\//\\//\\
//  \\//\\//\\//\\//\\//\\//\\//\\

//
// td version for dcPSP analysis
//
//  \\//\\//\\//\\//\\//\\//\\//\\
//\\//\\//\\//\\//\\//\\//\\//\\

macro dcPSP()
variable peaksign = 1			// sets optional parameter to determine sign of peak, +1 for positive, -1 for negative peak

// required parameters
variable m_rin = 1 			// disable input resistance measurement, only works for current clamp :: DO NOT SET TO 1 unless you are pro ::
variable use_csr = 0	 		// :: -1 use x-axis for range, :: 0 use default range -inf, inf sec, :: 1 use cursors A and B for range

// optional parameters in function call
variable trace 					// set tr = trace if you want to specify which trace, only use if multiple traces
variable baseline	= 0.25	// set bsl = baseline if you want to specify when the baseline is taken

variable xstart = 0.4
variable xend = 0.5			// set xs = xstart, xe = xend to specify a manual range for peak detection and analysis

variable peakwin = 0.01		// set pwin = peakwin, this sets the window to search for the peak if multiple peaks, starts at xstart 

print eventM( m_rin, use_csr, bsl = baseline, xs = xstart, xe = xend, pwin = peakwin, psign = peaksign )

endmacro
//\\//\\//\\//\\//\\//\\//\\//\\
//  \\//\\//\\//\\//\\//\\//\\//\\

//
// td version for dcPSP analysis
//
//  \\//\\//\\//\\//\\//\\//\\//\\
//\\//\\//\\//\\//\\//\\//\\//\\

macro dcPSP_completo()
variable peaksign = 1			// sets optional parameter to determine sign of peak, +1 for positive, -1 for negative peak

	// required parameters
	variable m_rin = 1 			// disable input resistance measurement, only works for current clamp :: DO NOT SET TO 1 unless you are pro ::
	variable use_csr = 0	 		// :: -1 use x-axis for range, :: 0 use default range -inf, inf sec, :: 1 use cursors A and B for range
	
	// optional parameters in function call
	variable trace 					// set tr = trace if you want to specify which trace, only use if multiple traces
	variable baseline	= 0.25	// set bsl = baseline if you want to specify when the baseline is taken
	
	variable xstart = 0.3
	variable xend = 0.4			// set xs = xstart, xe = xend to specify a manual range for peak detection and analysis
	variable xinc = 0.01
	
	variable peakwin = 0.015		// set pwin = peakwin, this sets the window to search for the peak if multiple peaks, starts at xstart 
	string nm = "first_", holder=""
	string wlist = winlist("*", ";", ""), panelwin = stringfromlist( 0, wlist )
	string tablen = "dcPSPcompleto"
	variable imax = 11
	
	string pathn = "collector_data", passwn = "", passTablen="", targetwn = "", expcode = ""

	targetwn = removequotes( stringfromlist( 0, tracenamelist( "", ";", 1 ) ) )
	expcode = removequotes( datecodefromanything( targetwn ) )
	passTablen = "T_" + expcode + "_0"
	
	// 1st pulse
	holder = eventM( m_rin, use_csr, bsl = baseline, xs = xstart, xe = xend, xinc = xinc, pwin = peakwin, psign = peaksign, name = nm, tablen = tablen, maxsweep = imax )
	
	xstart = 0.4
	xend = 0.5			// set xs = xstart, xe = xend to specify a manual range for peak detection and analysis
	xinc = 0.0
	peakwin = 0.015		// set pwin = peakwin, this sets the window to search for the peak if multiple peaks, starts at xstart 
	// 2nd pulse
	dowindow/F $panelwin
	nm = "second_"
	holder = eventM( m_rin, use_csr, bsl = baseline, xs = xstart, xe = xend, xinc = xinc, pwin = peakwin, psign = peaksign, name = nm, tablen = tablen, maxsweep = imax )
	
	dowindow/F $panelwin

	passwn = passiveSandwich( setpathn = pathn, passiveTablen = passTablen, targetwn = targetwn ) // acts on top window!
	
	dowindow/F $tablen
	//WAVE/Z pw = $passwn
	//if( waveexists( pw ) )
	if( waveexists( $passwn ) )
		appendtotable/W=$tablen $passwn
	endif
	equilibrateTable()

endmacro

//\\//\\//\\//\\//\\//\\//\\//\\
//  \\//\\//\\//\\//\\//\\//\\//\\

//
// td version for dcPSP analysis
//
//  \\//\\//\\//\\//\\//\\//\\//\\
//\\//\\//\\//\\//\\//\\//\\//\\

macro dcPSP_batchMode( increment )
	variable increment = 0.01 // default is to increment timing of 1st pulse

// get list of series for batch mode
	string series_list = "", series_listw = "serieslistw", series_list_selw = "", listboxn = "list_series", pathn = "collector_data"

//	WAVE/Z/T slistw = serieslistw // $series_listw
	if( !waveexists( $series_listw ) )
		print "no series wave for batchmode:", series_listw
		abort
	endif 
	string sweeplist = returnallwavesfromserieslist( "", tracen = 1, slistw = $series_listw, pathn = pathn )
	//print "here is the series list:", sweeplist

	variable isweeps = 0, nsweeps = itemsinlist( sweeplist ) 

//	string wavel = returnwavesfromseries( serieslistw[0], tracen = 1, pathn = pathn )
	string wlist = winlist("*", ";", ""), panelwin = stringfromlist( 0, wlist )
	string tablen = "dcPSP_batchMode0"
	string passwn = "", passTablen="", targetwn = "", expcode = ""
	targetwn = removequotes( stringfromlist( 0, sweeplist ) )
	expcode = removequotes( datecodefromanything( targetwn ) )
	passTablen = "T_" + expcode + "_0"

	string PGFlabel = stringbykey( "LABEL", note( $targetwn ) )

	// assemble the batch mode wave list

	variable peaksign = 1			// sets optional parameter to determine sign of peak, +1 for positive, -1 for negative peak

	// required parameters
	variable m_rin = 1 			// 0 disable input resistance measurement, only works for current clamp :: DO NOT SET TO 1 unless you are pro ::
	variable use_csr = 0	 	// :: -1 use x-axis for range, :: 0 use default range -inf, inf sec, :: 1 use cursors A and B for range
	
	// optional parameters in function call
	variable trace 				// set tr = trace if you want to specify which trace, only use if multiple traces
	variable baseline	= 0.25	// set bsl = baseline if you want to specify when the baseline is taken
	
	variable xstart = 0.2 // 0.3
	variable xend = 0.3 //0.4			// set xs = xstart, xe = xend to specify a manual range for peak detection and analysis
	variable xinc = increment // 0.01

	variable peakwin = 0.015	// set pwin = peakwin, this sets the window to search for the peak if multiple peaks, starts at xstart 
	string nm = expcode + PGFlabel + "_1", holder=""
	tablen = "T_" + expcode +  "_dcPSP_BM0"
	variable imax = nsweeps
	variable ignoreSweep = 11 // ignores sweeps >= to param
	variable target_baseline = -75 // mV
	variable target_thresh = 2 // mV range

	//for( isweep = 0; isweep < nsweeps; ++ isweep )
		// 1st pulse
		dowindow/F $panelwin
		xstart = 0.2  //0.3
		xend = 0.3			// set xs = xstart, xe = xend to specify a manual range for peak detection and analysis
		xinc = 0.01 //0 // 0.01
		peakwin = 0.015		// set pwin = peakwin, this sets the window to search for the peak if 
		if( strlen( pgflabel ) > 6 )
			print "BATCH MODE warning pgflabel too long", pgflabel
			pgflabel = "a"
	
		endif
		nm = expcode + PGFlabel + "_1"
		holder = eventM( m_rin, use_csr, bsl = baseline, xs = xstart, xe = xend, xinc = xinc, pwin = peakwin, psign = peaksign, name = nm, tablen = tablen, maxsweep = imax, wlist = sweeplist, ignoreSweep = ignoreSweep, target_baseline = target_baseline, target_threshold = target_thresh )

		// 2nd pulse	
		dowindow/F $panelwin
		xstart = 0.4
		xend = 0.5			// set xs = xstart, xe = xend to specify a manual range for peak detection and analysis
		xinc = 0.0
		peakwin = 0.015		// set pwin = peakwin, this sets the window to search for the peak if multiple peaks, starts at xstart 
		nm = expcode + PGFlabel + "_2"
		holder = eventM( m_rin, use_csr, bsl = baseline, xs = xstart, xe = xend, xinc = xinc, pwin = peakwin, psign = peaksign, name = nm, tablen = tablen, maxsweep = imax, wlist = sweeplist, target_baseline = target_baseline, target_threshold = target_thresh )
		
		dowindow/F $panelwin

		graphResults( expcode, PGFlabel )



		// passwn = passiveSandwich( setpathn = pathn, passiveTablen = passTablen, targetwn = targetwn ) // acts on top window!
		
		// dowindow/F $tablen
		// if( waveexists( $passwn ) )
		// 	appendtotable/W=$tablen $passwn
		// endif
		// equilibrateTable()
	//endfor
endmacro 
// end of dcPSP batchmode

//\\//\\//\\//\\//\\//\\//\\//\\
//  \\//\\//\\//\\//\\//\\//\\//\\

//
// td version for dcPSP analysis
//
//  \\//\\//\\//\\//\\//\\//\\//\\
//\\//\\//\\//\\//\\//\\//\\//\\

macro dcPSP_beastMode(wlwn)

	// provide a text wave listing the series for analysis	
	string wlwn = "g2"
	string series_listw = wlwn

	string series_list = "", series_list_selw = "", listboxn = "list_series", pathn = "collector_data"

//	WAVE/Z/T slistw = serieslistw // $series_listw
	if( !waveexists( $series_listw ) )
		print "no series wave for batchmode:", series_listw
		abort
	endif 
	string sweeplist = returnallwavesfromserieslist( "", tracen = 1, slistw = $series_listw, pathn = pathn )
	//print "here is the series list:", sweeplist

	variable isweeps = 0, nsweeps = itemsinlist( sweeplist ) 

//	string wavel = returnwavesfromseries( serieslistw[0], tracen = 1, pathn = pathn )
	string wlist = winlist("*", ";", ""), panelwin = stringfromlist( 0, wlist )
	string tablen = "dcPSP_batchMode0"
	string passwn = "", passTablen="", targetwn = "", expcode = ""
	targetwn = removequotes( stringfromlist( 0, sweeplist ) )
	expcode = removequotes( datecodefromanything( targetwn ) )
	passTablen = "T_" + expcode + "_0"

	string PGFlabel = stringbykey( "LABEL", note( $targetwn ) )

	// assemble the batch mode wave list

	variable peaksign = 1			// sets optional parameter to determine sign of peak, +1 for positive, -1 for negative peak

	// required parameters
	variable m_rin = 1 			// 0 disable input resistance measurement, only works for current clamp :: DO NOT SET TO 1 unless you are pro ::
	variable use_csr = 0	 	// :: -1 use x-axis for range, :: 0 use default range -inf, inf sec, :: 1 use cursors A and B for range
	
	// optional parameters in function call
	variable trace 				// set tr = trace if you want to specify which trace, only use if multiple traces
	variable baseline	= 0.25	// set bsl = baseline if you want to specify when the baseline is taken
	
	variable xstart = 0.3
	variable xend = 0.4			// set xs = xstart, xe = xend to specify a manual range for peak detection and analysis
	variable xinc = 0.01
	
	variable peakwin = 0.015	// set pwin = peakwin, this sets the window to search for the peak if multiple peaks, starts at xstart 
	string nm, holder //= expcode + PGFlabel + "_1", holder=""
	tablen = "T_" + expcode +  "_dcPSP_BM0"
	variable imax = nsweeps
	variable ignoreSweep = 11 // ignores sweeps >= to param
	variable target_baseline = -75 // mV
	variable target_thresh = 2 // mV range


		// 1st pulse

		xstart = 0.3
		xend = 0.4			// set xs = xstart, xe = xend to specify a manual range for peak detection and analysis
		xinc = 0.01
		peakwin = 0.015		// set pwin = peakwin, this sets the window to search for the peak if 
	
		//nm = expcode + PGFlabel + "_1"
		nm = wlwn + "_1"
		holder = eventM( m_rin, use_csr, bsl = baseline, xs = xstart, xe = xend, xinc = xinc, pwin = peakwin, psign = peaksign, name = nm, tablen = tablen, maxsweep = imax, wlist = sweeplist, ignoreSweep = ignoreSweep, target_baseline = target_baseline, target_threshold = target_thresh )


		// 2nd pulse	

		xstart = 0.4
		xend = 0.5			// set xs = xstart, xe = xend to specify a manual range for peak detection and analysis
		xinc = 0.0
		peakwin = 0.015		// set pwin = peakwin, this sets the window to search for the peak if multiple peaks, starts at xstart 
	
		//nm = expcode + PGFlabel + "_2"
		nm = wlwn + "_2"
		holder = eventM( m_rin, use_csr, bsl = baseline, xs = xstart, xe = xend, xinc = xinc, pwin = peakwin, psign = peaksign, name=nm, tablen = tablen, maxsweep = imax, wlist = sweeplist, target_baseline = target_baseline, target_threshold = target_thresh )
		

		// process and display

		//graphResults( expcode, PGFlabel )

	pgflabel = "" // totally faking it here
	graphResults( wlwn, PGFlabel )



endmacro 
// end of dcPSP beastmode


//\\//\\//\\//\\//\\//\\//\\//\\
//  \\//\\//\\//\\//\\//\\//\\//\\

//
// td version for dcPSP analysis
//
//  \\//\\//\\//\\//\\//\\//\\//\\
//\\//\\//\\//\\//\\//\\//\\//\\

macro dcPSP_1stpulse()
variable peaksign = 1			// sets optional parameter to determine sign of peak, +1 for positive, -1 for negative peak

// required parameters
variable m_rin = 1 			// disable input resistance measurement, only works for current clamp :: DO NOT SET TO 1 unless you are pro ::
variable use_csr = 0	 		// :: -1 use x-axis for range, :: 0 use default range -inf, inf sec, :: 1 use cursors A and B for range

// optional parameters in function call
variable trace 					// set tr = trace if you want to specify which trace, only use if multiple traces
variable baseline	= 0.25	// set bsl = baseline if you want to specify when the baseline is taken

variable xstart = 0.3
variable xend = 0.4			// set xs = xstart, xe = xend to specify a manual range for peak detection and analysis
variable xinc = 0.01

variable peakwin = 0.01		// set pwin = peakwin, this sets the window to search for the peak if multiple peaks, starts at xstart 
string nm = ""
print eventM( m_rin, use_csr, bsl = baseline, xs = xstart, xe = xend, xinc = xinc, pwin = peakwin, psign = peaksign, name = nm, tablen = "Test" )

endmacro

//\\//\\//\\//\\//\\//\\//\\//\\
//  \\//\\//\\//\\//\\//\\//\\//\\

//
// td version for dcPSP analysis
//
//  \\//\\//\\//\\//\\//\\//\\//\\
//\\//\\//\\//\\//\\//\\//\\//\\

macro dcPSP_2ndPulse()
variable peaksign = 1			// sets optional parameter to determine sign of peak, +1 for positive, -1 for negative peak

// required parameters
variable m_rin = 1 			// disable input resistance measurement, only works for current clamp :: DO NOT SET TO 1 unless you are pro ::
variable use_csr = 0	 		// :: -1 use x-axis for range, :: 0 use default range -inf, inf sec, :: 1 use cursors A and B for range

// optional parameters in function call
variable trace 					// set tr = trace if you want to specify which trace, only use if multiple traces
variable baseline	= 0.25	// set bsl = baseline if you want to specify when the baseline is taken

variable xstart = 0.4
variable xend = 0.5			// set xs = xstart, xe = xend to specify a manual range for peak detection and analysis
variable xinc = 0.0

variable peakwin = 0.01		// set pwin = peakwin, this sets the window to search for the peak if multiple peaks, starts at xstart 

print eventM( m_rin, use_csr, bsl = baseline, xs = xstart, xe = xend, xinc = xinc, pwin = peakwin, psign = peaksign )

endmacro



macro buildMKP()
	variable ntabs = 5
	buildmasterkinpanel( ntabs )
endmacro

macro passSandwich()
	string pathn = "collector_data"
	print passiveSandwich( setpathn = pathn )
endmacro


macro ap( )
	variable offset = 0.1 // delay to the stimulus pulse
	variable trace = -1, smoothing = 10, threshold = 2
	threshold = getparam( "Derivative cutoff", "Enter derivative cutoff (V/s):", 2 )
	offset = getparam( "Delay to step", "Enter delay to step (s):", 0.1 )

	print appropV2_2( trace, smoothing, threshold, disp=2, delay=offset )
	print threshold

end


macro makeBlastPanel()

	makeBPfunc()

end


macro refreshBlastPanel()

	refreshdetect()

end

macro refreshInt()
 
	refreshintervals()

end

macro refreshT50R( )
variable thissign = -1
variable disp = 1

refreshrisetimes( thissign, disp = 1 ) //, disp = 1 )

endmacro