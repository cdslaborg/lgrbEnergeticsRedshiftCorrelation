function distSq = getDistSq(x)
    global logZoneCurrent logEisoCurrent
    distSq = (getLogThreshLim(x) - logEisoCurrent ).^2 + (x-logZoneCurrent).^2;
end