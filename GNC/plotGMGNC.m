x = linspace(-3,3,100);
c = 1;
mu = 100;
f = @(x) mu*c^2*x.^2./(mu*c^2+x.^2);
fo = @(x) x.^2;
plot(x,f(x))

hold on
mu = 10;
f = @(x) mu*c^2*x.^2./(mu*c^2+x.^2);
plot(x,f(x))

mu = 2;
f = @(x) mu*c^2*x.^2./(mu*c^2+x.^2);
plot(x,f(x))

plot(x,fo(x))
legend('\mu = 100','\mu = 10','\mu = 2','original')
axis([-3,3,0,9])
grid on
xlabel('residual')
ylabel('objective function')