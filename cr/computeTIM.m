function out = computeTIM(v)
N = size(v,2);
out = zeros(3,N*(N-1)/2);
for i = 0:N-1
    idx = i*N-i*(i+1)/2+1;
    cols = N-1-i;
    m = v(:,i+1);
    temp = v - repmat(m,1,N);
    out(1:3,idx:idx+cols-1) = temp(:,end-cols+1:end);
%     map = zeros(2,N);
%     for j = 0:N-1
%         map(1,j+1) = i+1;
%         map(2,j+1) = j+1;
%     end
%     out(4:5,idx:idx+cols-1) = map(:,end-cols+1:end);
end
end