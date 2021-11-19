function error = getAngularError(R,Rt)
error = abs(acos(min(max((trace(Rt'*R)-1)/2,-1),1)));
end