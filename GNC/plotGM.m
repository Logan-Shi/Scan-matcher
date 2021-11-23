x = linspace(-3,3,100);
c = 1;
f = @(x) c^2*x.^2./(c^2+x.^2);
fo = @(x) x.^2;
plot(x,f(x))
hold on
c = 2;
f = @(x) c^2*x.^2./(c^2+x.^2);
plot(x,f(x))
plot(x,fo(x))
legend('c = 1','c = 2','original')
axis([-3,3,0,9])
grid on
xlabel('residual')
ylabel('objective function')