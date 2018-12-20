i = 0 // first spike
// make intervals



if ( intervals[ i ] < burstwindow )

  if ( intervals[ i+1 ] < burstwindow )

    // it's in a burst, spike before and after

  else

    // it's ending a burst, no spike after

  endif

else // if interval is > burstwindow :: no spike before this one

  if ( intervals[ i+1 ] < burstwindow ) )

    // it's starting a burst

  else

    // it's a single spike!

  endif
