clear all; close all;
N = 100;
r = linspace(-3,3,N);
c = 1;
for i = 1:N
    if r(i)^2<c^2
        f1(i) = r(i)^2;
    else
        f1(i) = c^2;
    end
end
plot(r,f1)
hold on
c = 2;
for i = 1:N
    if r(i)^2<c^2
        f1(i) = r(i)^2;
    else
        f1(i) = c^2;
    end
end
plot(r,f1)
plot(r,r.^2)
legend('c = 1','c = 2','original')
axis([-3,3,0,9])
grid on
xlabel('residual')
ylabel('objective function')