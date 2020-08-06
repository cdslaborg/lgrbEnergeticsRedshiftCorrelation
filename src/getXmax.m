function xmax = getXmax(xvec,yvec,threshLim,getThreshLim)
    ndata = length(xvec);
    if ndata~=length(yvec)
        error("ndata~=length(y): " + string(xvec) + " " + string(yvec) );
    end

    xmax = zeros(ndata,1);
    for i = 1:ndata

        getLimNew = @(x) abs(getThreshLim(x,threshLim) - yvec(i));
        options = optimset("MaxIter", 10000, "MaxFunEvals", 10000);
        [x, funcVal, exitflag, output] = fminsearch(getLimNew, xvec(i), options);

        if exitflag==1
            xmax(i) = x;
        else
            disp("failed at iteration " + string(i) + " with xvec(i) = " + string(xvec(i)) + ", yvec(i) = " + string(yvec(i)) + " with fval = " + string(fval) );
            i
            xvec(i)
            yvec(i)
            output
        end

    end

end
