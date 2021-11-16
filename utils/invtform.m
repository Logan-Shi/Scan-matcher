function invT = invtform(T)
R = T(1:3,1:3);
t = T(1:3,4);
invT = [R' -R'*t;
        zeros(1,3) 1];
end

