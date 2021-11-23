clear all; close all;
N = 100;
r = linspace(-3,3,N);
c = 1;
mu = 0.01;
for i = 1:N
    if r(i)^2<mu/(mu+1)*c^2
        f1(i) = r(i)^2;
    elseif r(i)^2<(mu+1)/mu*c^2
        f1(i) = 2*c*abs(r(i))*sqrt(mu*(mu+1))-mu*(c^2+r(i)^2);
    else
        f1(i) = c^2;
    end
end
plot(r,f1)
hold on
mu = 1;
for i = 1:N
    if r(i)^2<mu/(mu+1)*c^2
        f1(i) = r(i)^2;
    elseif r(i)^2<(mu+1)/mu*c^2
        f1(i) = 2*c*abs(r(i))*sqrt(mu*(mu+1))-mu*(c^2+r(i)^2);
    else
        f1(i) = c^2;
    end
end
plot(r,f1)
hold on
mu = 2;
for i = 1:N
    if r(i)^2<mu/(mu+1)*c^2
        f1(i) = r(i)^2;
    elseif r(i)^2<(mu+1)/mu*c^2
        f1(i) = 2*c*abs(r(i))*sqrt(mu*(mu+1))-mu*(c^2+r(i)^2);
    else
        f1(i) = c^2;
    end
end
plot(r,f1)
plot(r,r.^2)
legend('mu = 0.01','mu = 1','mu = 2','original')
axis([-3,3,0,9])
grid on
xlabel('residual')
ylabel('objective function')