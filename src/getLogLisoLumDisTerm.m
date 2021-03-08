function logLisoLumDisTerm = getLogLisoLumDisTerm(zplus1)
    % Return the term that appears in the mapping of the peak flux to the peak luminosity for log(z+1)>1.1.
    % logLiso = logFlux + logLisoLumDisTerm

    MPC2CM = 3.09e24;                           % 1 Mega Parsec = MPC2CM centimeters.
    LOGMPC2CMSQ4PI = log(4*pi) + 2*log(MPC2CM); % log(MegaParsec2centimeters).

    logLisoLumDisTerm = LOGMPC2CMSQ4PI + 2 * getLogLumDisWicMPC(zplus1);

end