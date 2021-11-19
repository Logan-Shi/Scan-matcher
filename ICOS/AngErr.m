function error = AngErr(R, R_gt)

error = abs(acos((trace(R'*R_gt)-1)/2));

end