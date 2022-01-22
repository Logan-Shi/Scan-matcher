clear;clc;

obj = 'bunny';
surfix = strcat('./data/',obj,'/');
batch_size = 10;

filename = strcat(surfix,'bunny.conf');
[ptCloud,Ts] = read_mesh_conf(surfix,obj,batch_size);

save([surfix,'/ptCloud_raw.mat'],'ptCloud')
save([surfix,'/Ts_test_benchmark.mat'],'Ts')