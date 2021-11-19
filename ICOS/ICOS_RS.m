function [R_opt,inlier_set]=ICOS_RS(n_ele,noise,pts_3d,pts_3d_,X)


for itr_RANSAC=1:1e+8
    
    
    for ss=1:40000
        
        scale_set_this=randperm(n_ele,2);
        
        length_a=norm(pts_3d(scale_set_this(1),:)-pts_3d(scale_set_this(2),:));
        
        length_b=norm(pts_3d_(scale_set_this(1),:)-pts_3d_(scale_set_this(2),:));
        
        check_increase=0;
        
        if abs((length_a-length_b))<=0.025 %0.008 0.1
            
            v12=pts_3d(scale_set_this(1),:);
            X_axis=v12';
            v13=pts_3d(scale_set_this(2),:);
            v23=cross(v12,v13);
            Y_axis=v23'/norm(v23);
            Z_axis=cross(X_axis,Y_axis);
            
            v12=pts_3d_(scale_set_this(1),:);
            X_axis_=v12';
            v13=pts_3d_(scale_set_this(2),:);
            v23=cross(v12,v13);
            Y_axis_=v23'/norm(v23);
            Z_axis_=cross(X_axis_,Y_axis_);
            
            R_raw=[X_axis_,Y_axis_,Z_axis_]*[X_axis,Y_axis,Z_axis]';
            
            check_increase=1;
            
            break
            
        end
        
    end
    
    if check_increase==1
        
        check_in=0;
        
        inlier_set=scale_set_this;
        
        
        for samp=1:X*400
            
            label=0;
            for iiii=1:X-1
                if samp>=iiii*400 && check_in<iiii
                    label=1;
                    break
                end
            end
            if label==1
                break
            end
            
            
            for sampling=1:1e+10
                scale_set_add=randperm(n_ele,1);
                if  ismember(scale_set_add,inlier_set)-1
                    break
                end
            end
            
            
            if  norm(R_raw*pts_3d(scale_set_add,:)'-pts_3d_(scale_set_add,:)')<=4*noise
                
                
                length_a1=norm(pts_3d(scale_set_this(1),:)-pts_3d(scale_set_add,:));
                
                
                length_b1=norm(pts_3d_(scale_set_this(1),:)-pts_3d_(scale_set_add,:));
                
                
                length_a2=norm(pts_3d(scale_set_this(2),:)-pts_3d(scale_set_add,:));
                
                
                length_b2=norm(pts_3d_(scale_set_this(2),:)-pts_3d_(scale_set_add,:));
                
                
                if abs((length_a1-length_b1))<=0.023 && abs((length_a2-length_b2))<=0.023  %0.008 0.1
                    
                    
                    v12=pts_3d(scale_set_this(1),:);
                    X_axis=v12'/norm(v12);
                    v13=pts_3d(scale_set_add,:);
                    v23=cross(v12,v13);
                    Y_axis=v23'/norm(v23);
                    Z_axis=cross(X_axis,Y_axis);
                    
                    v12=pts_3d_(scale_set_this(1),:);
                    X_axis_=v12'/norm(v12);
                    v13=pts_3d_(scale_set_add,:);
                    v23=cross(v12,v13);
                    Y_axis_=v23'/norm(v23);
                    Z_axis_=cross(X_axis_,Y_axis_);
                    
                    R_raw1=[X_axis_,Y_axis_,Z_axis_]*[X_axis,Y_axis,Z_axis]';
                    
                    
                    
                    v12=pts_3d(scale_set_this(2),:);
                    X_axis=v12'/norm(v12);
                    v13=pts_3d(scale_set_add,:);
                    v23=cross(v12,v13);
                    Y_axis=v23'/norm(v23);
                    Z_axis=cross(X_axis,Y_axis);
                    
                    v12=pts_3d_(scale_set_this(2),:);
                    X_axis_=v12'/norm(v12);
                    v13=pts_3d_(scale_set_add,:);
                    v23=cross(v12,v13);
                    Y_axis_=v23'/norm(v23);
                    Z_axis_=cross(X_axis_,Y_axis_);
                    
                    R_raw2=[X_axis_,Y_axis_,Z_axis_]*[X_axis,Y_axis,Z_axis]';
                    
                    if AngErr(R_raw,R_raw1)*180/pi<=6 && AngErr(R_raw,R_raw2)*180/pi<=6 && ...
                            AngErr(R_raw1,R_raw2)*180/pi<=6
                        
                        
                        check_in=check_in+1;
                        
                        inlier_set=[inlier_set,scale_set_add];
                        
                    end
                    
                end
                
            end
            
            
            
            
            
            if   check_in>=X
                
                break
                
            end
            
        end
        
        if check_in>=X
            
            
            
            H=zeros(3,3);
            for i=1:length(inlier_set)
                H=H+(pts_3d(inlier_set(i),:)')*pts_3d_(inlier_set(i),:);
            end
            
            [U,~,V]=svd(H);
            
            R_opt=V*U';
            
            break
            
        end
        
    end
    
    
end

inlier_set=zeros(1,1);cou=0;

for i=1:n_ele
    
    re=norm(R_opt*pts_3d(i,:)'-pts_3d_(i,:)');
    
    if re<=4*1.7*noise
        
        cou=cou+1;
        
        inlier_set(cou)=i;
        
    end
    
end


H=zeros(3,3);
for i=1:length(inlier_set)
    H=H+(pts_3d(inlier_set(i),:)')*pts_3d_(inlier_set(i),:);
end

[U,~,V]=svd(H);

R_opt=V*U';


end