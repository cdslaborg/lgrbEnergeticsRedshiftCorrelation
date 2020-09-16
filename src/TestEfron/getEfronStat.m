function epstat = getEfronStat(xvec,yvec,xmax)
    ndata = length(xvec);
    if ndata~=length(yvec)
        error("ndata~=length(y): " + string(xvec) + " " + string(yvec) );
    end

    epstat = struct();
    epstat.xmax = xmax;
    epstat.box.mask = cell(ndata,1);
    epstat.box.count = zeros(ndata,1);
    epstat.box.rankAvg = zeros(ndata,1);
    epstat.box.rankVar = zeros(ndata,1);
    epstat.box.rank = zeros(ndata,1);

    for i = ndata:-1:1

        epstat.box.mask{i} = xvec <= epstat.xmax(i) & yvec >= yvec(i);
        epstat.box.count(i) = sum( epstat.box.mask{i} );
        xmaxBoxXvec = xvec(epstat.box.mask{i});
        epstat.box.rank(i) = sum( xmaxBoxXvec < xvec(i) );
        epstat.box.rankAvg(i) = ( epstat.box.count(i) + 1 ) * 0.5;
        epstat.box.rankVar(i) = ( epstat.box.count(i)^2 - 1 ) / 12.;

    end

    %xmax.box.rankStd = sqrt(xmax.box.rankVar);
    epstat.tau = sum( epstat.box.rank - epstat.box.rankAvg ) / sqrt( sum( epstat.box.rankVar ) );
    %xmax.tau = sum( (xmax.box.rank(:) - xmax.box.rankAvg(:)) ./ xmax.box.rankStd(:) );

end

