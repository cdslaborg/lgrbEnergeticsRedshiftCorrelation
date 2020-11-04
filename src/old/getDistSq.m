function distSq = getDistSq(x)
    global logZoneCurrent logLisoCurrent
    distSq = (getLogThreshLim(x) - logLisoCurrent ).^2 + (x-logZoneCurrent).^2;
end