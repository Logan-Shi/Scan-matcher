function R = randRotation()
% rotation
u1 = rand(1);
u2 = 2*pi*rand(1);
u3 = 2*pi*rand(1);
a = sqrt(1-u1);
b = sqrt(u1);
q = [a*sin(u2),a*cos(u2),b*sin(u3),b*cos(u3)];
R = quat2rotm(q);
end