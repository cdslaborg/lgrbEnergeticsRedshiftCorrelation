function logEisoLumDisTerm = getLogEisoLumDisTerm(zplus1)
    % Return the term that appears in the mapping of a GRB fluence to the total isotropic energy for log(z+1)>1.1.
    % logEiso = logFluence + logEisoLumDisTerm
    logEisoLumDisTerm = getLogLisoLumDisTerm(zplus1) - log(zplus1);
end