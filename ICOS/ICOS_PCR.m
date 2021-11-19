function [R_opt,t_opt,scale_opt,inlier_set]=ICOS_PCR(n_ele,noise,pts_3d,pts_3d_,known_scale)

X=4;

if known_scale==1
    
    noise_bound=4.5;
    
    noise_bound_=5;
    
    for itr_RANSAC=1:1e+10
        
        inlier_set=[];
        
        
        for ss=1:40000
            
            scale_set_this=randperm(n_ele,2);
            
            if abs(norm(pts_3d_(scale_set_this(1),:)'-pts_3d_(scale_set_this(2),:)')/norm(pts_3d(scale_set_this(1),:)'-pts_3d(scale_set_this(2),:)')-1)<=0.052/norm(pts_3d(scale_set_this(1),:)'-pts_3d(scale_set_this(2),:)')
                
                for ssa=1:400
                    new_add=randperm(n_ele,1);
                    if min([abs(new_add-scale_set_this(1)),abs(new_add-scale_set_this(2))])~=0
                        
                        if abs(norm(pts_3d_(scale_set_this(1),:)'-pts_3d_(new_add,:)')/norm(pts_3d(scale_set_this(1),:)'-pts_3d(new_add,:)')-1)<=0.052/norm(pts_3d(scale_set_this(1),:)'-pts_3d(new_add,:)') && ...
                                abs(norm(pts_3d_(scale_set_this(2),:)'-pts_3d_(new_add,:)')/norm(pts_3d(scale_set_this(2),:)'-pts_3d(new_add,:)')-1)<=0.052/norm(pts_3d(scale_set_this(2),:)'-pts_3d(new_add,:)')
                            
                            break
                            
                        end
                    end
                end
                
                scale_set_this=[scale_set_this,new_add];
                break
                
            end
            
        end
        
        
        s_=zeros(3,1);s_weight=zeros(3,1);count_=0;p_tilde=zeros(3,1);mean_s=0;
        
        for i=1:2
            for j=i+1:3
                count_=count_+1;
                p_tilde(count_)=norm(pts_3d(scale_set_this(i),:)'-pts_3d(scale_set_this(j),:)');
                s_(count_)=norm(pts_3d_(scale_set_this(i),:)'-pts_3d_(scale_set_this(j),:)')/p_tilde(count_);
                s_weight(count_)=p_tilde(count_)^2/0.01;
                mean_s=mean_s+s_(count_)*s_weight(count_);
            end
        end
        
        mean_s=mean_s/sum(s_weight);
        
        
        if   max(s_)-min(s_)<=0.1*mean_s && abs(mean_s-1)<=0.06
            
            
            if   abs(s_(1)-s_(2))<=noise_bound*noise/p_tilde(1)+noise_bound*noise/p_tilde(2) && ...
                    abs(s_(1)-s_(3))<=noise_bound*noise/p_tilde(1)+noise_bound*noise/p_tilde(3) && ...
                    abs(s_(2)-s_(3))<=noise_bound*noise/p_tilde(2)+noise_bound*noise/p_tilde(3)
                
                v12=pts_3d(scale_set_this(2),:)-pts_3d(scale_set_this(1),:);
                X_axis=v12'/norm(v12);
                v13=pts_3d(scale_set_this(3),:)-pts_3d(scale_set_this(1),:);
                v23=cross(v12,v13);
                Y_axis=v23'/norm(v23);
                Z_axis=cross(X_axis,Y_axis);
                
                v12=pts_3d_(scale_set_this(2),:)-pts_3d_(scale_set_this(1),:);
                X_axis_=v12'/norm(v12);
                v13=pts_3d_(scale_set_this(3),:)-pts_3d_(scale_set_this(1),:);
                v23=cross(v12,v13);
                Y_axis_=v23'/norm(v23);
                Z_axis_=cross(X_axis_,Y_axis_);
                
                R_raw=[X_axis_,Y_axis_,Z_axis_]*[X_axis,Y_axis,Z_axis]';
                
                t_raw1=(pts_3d_(scale_set_this(1),:))'-mean_s*R_raw*((pts_3d(scale_set_this(1),:)))';
                t_raw2=(pts_3d_(scale_set_this(2),:))'-mean_s*R_raw*((pts_3d(scale_set_this(2),:)))';
                t_raw3=(pts_3d_(scale_set_this(3),:))'-mean_s*R_raw*((pts_3d(scale_set_this(3),:)))';
                
                
                if   norm(t_raw1 - t_raw2) <= noise*noise_bound_ && norm(t_raw1 - t_raw3) <= noise*noise_bound_ && ...
                        norm(t_raw2 - t_raw3) <= noise*noise_bound_
                    
                    
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
                        
                        s_=zeros(3,1);s_weight=zeros(3,1);count_=0;p_tilde=zeros(3,1);mean_s_=0;
                        
                        lee=length(inlier_set);
                        
                        for i=1:lee
                            
                            p_tilde(i)=norm(pts_3d(inlier_set(i),:)'-pts_3d(scale_set_add,:)');
                            s_(i)=norm(pts_3d_(inlier_set(i),:)'-pts_3d_(scale_set_add,:)')/p_tilde(i);
                            s_weight(i)=p_tilde(i)^2/0.01;
                            mean_s_=mean_s_+s_weight(i)*s_(i);
                            
                        end
                        
                        mean_s_=mean_s_/sum(s_weight);
                        
                        if    max(s_)-min(s_)<=0.1*mean_s_ && abs(mean_s-mean_s_)<=0.06*1
                            
                            mean_t=(t_raw1+t_raw2+t_raw3)/3;
                            
                            if    abs(s_(1)-s_(2))<=noise_bound*noise/p_tilde(1)+noise_bound*noise/p_tilde(2) && ...
                                    abs(s_(1)-s_(3))<=noise_bound*noise/p_tilde(1)+noise_bound*noise/p_tilde(3) && ...
                                    abs(s_(2)-s_(3))<=noise_bound*noise/p_tilde(2)+noise_bound*noise/p_tilde(3) && ...
                                    norm(1*R_raw*pts_3d(scale_set_add,:)'+mean_t-pts_3d_(scale_set_add,:)')<=1.2*noise_bound_*noise
                                
                                
                                
                                v12=pts_3d(scale_set_this(2),:)-pts_3d(scale_set_add,:);
                                X_axis=v12'/norm(v12);
                                v13=pts_3d(scale_set_this(3),:)-pts_3d(scale_set_add,:);
                                v23=cross(v12,v13);
                                Y_axis=v23'/norm(v23);
                                Z_axis=cross(X_axis,Y_axis);
                                
                                v12=pts_3d_(scale_set_this(2),:)-pts_3d_(scale_set_add,:);
                                X_axis_=v12'/norm(v12);
                                v13=pts_3d_(scale_set_this(3),:)-pts_3d_(scale_set_add,:);
                                v23=cross(v12,v13);
                                Y_axis_=v23'/norm(v23);
                                Z_axis_=cross(X_axis_,Y_axis_);
                                
                                R_raw1=[X_axis_,Y_axis_,Z_axis_]*[X_axis,Y_axis,Z_axis]';
                                
                                
                                
                                
                                v12=pts_3d(scale_set_this(2),:)-pts_3d(scale_set_add,:);
                                X_axis=v12'/norm(v12);
                                v13=pts_3d(scale_set_this(1),:)-pts_3d(scale_set_add,:);
                                v23=cross(v12,v13);
                                Y_axis=v23'/norm(v23);
                                Z_axis=cross(X_axis,Y_axis);
                                
                                v12=pts_3d_(scale_set_this(2),:)-pts_3d_(scale_set_add,:);
                                X_axis_=v12'/norm(v12);
                                v13=pts_3d_(scale_set_this(1),:)-pts_3d_(scale_set_add,:);
                                v23=cross(v12,v13);
                                Y_axis_=v23'/norm(v23);
                                Z_axis_=cross(X_axis_,Y_axis_);
                                
                                R_raw2=[X_axis_,Y_axis_,Z_axis_]*[X_axis,Y_axis,Z_axis]';
                                
                                
                                
                                v12=pts_3d(scale_set_this(1),:)-pts_3d(scale_set_add,:);
                                X_axis=v12'/norm(v12);
                                v13=pts_3d(scale_set_this(3),:)-pts_3d(scale_set_add,:);
                                v23=cross(v12,v13);
                                Y_axis=v23'/norm(v23);
                                Z_axis=cross(X_axis,Y_axis);
                                
                                v12=pts_3d_(scale_set_this(1),:)-pts_3d_(scale_set_add,:);
                                X_axis_=v12'/norm(v12);
                                v13=pts_3d_(scale_set_this(3),:)-pts_3d_(scale_set_add,:);
                                v23=cross(v12,v13);
                                Y_axis_=v23'/norm(v23);
                                Z_axis_=cross(X_axis_,Y_axis_);
                                
                                R_raw3=[X_axis_,Y_axis_,Z_axis_]*[X_axis,Y_axis,Z_axis]';
                                
                                if AngErr(R_raw,R_raw1)*180/pi<=7 && AngErr(R_raw,R_raw2)*180/pi<=7 && ...
                                        AngErr(R_raw,R_raw3)*180/pi<=7 && AngErr(R_raw1,R_raw2)*180/pi<=7 && ...
                                        AngErr(R_raw3,R_raw1)*180/pi<=7 && AngErr(R_raw2,R_raw3)*180/pi<=7
                                    
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
                        
                        
                        scale_set_this=inlier_set;
                        
                        q_=zeros(3,1);
                        p_=zeros(3,1);
                        
                        len=length(inlier_set);
                        
                        for i=1:len
                            
                            q_(1)=q_(1)+pts_3d_(scale_set_this(i),1);
                            q_(2)=q_(2)+pts_3d_(scale_set_this(i),2);
                            q_(3)=q_(3)+pts_3d_(scale_set_this(i),3);
                            
                            p_(1)=p_(1)+pts_3d(scale_set_this(i),1);
                            p_(2)=p_(2)+pts_3d(scale_set_this(i),2);
                            p_(3)=p_(3)+pts_3d(scale_set_this(i),3);
                            
                        end
                        
                        p_=p_/len;
                        q_=q_/len;
                        
                        s_=zeros(len,1);s_weight=zeros(len,1);p_tilde=zeros(len,1);
                        
                        for i=1:len
                            p_tilde(i)=norm(pts_3d(scale_set_this(i),:)'-p_);
                            s_(i)=norm(pts_3d_(scale_set_this(i),:)'-q_)/p_tilde(i);
                            s_weight(i)=p_tilde(i)^2/0.01;
                        end
                        
                        scale_opt=0;
                        
                        for i=1:len
                            scale_opt=scale_opt+s_(i)*s_weight(i);
                        end
                        
                        scale_opt=scale_opt/sum(s_weight);
                        
                        
                        inlier_set_raw=inlier_set;
                        
                        
                        n_ele_=length(inlier_set);
                        
                        pts_3d_new=pts_3d(inlier_set,:);
                        
                        pts_3d_new_=pts_3d_(inlier_set,:);
                        
                        
                        H=zeros(3,3);
                        for i=1:n_ele_
                            H=H+(pts_3d_new(i,:)'-p_)*(pts_3d_new_(i,:)'-q_)';
                        end
                        
                        [U,~,V]=svd(H);
                        
                        R_opt=V*U';
                        
                        t_opt=q_-scale_opt*R_opt*p_;
                        
                        inlier_set=zeros(1,1);
                        outlier_error=zeros(1,1);
                        inlier_error=zeros(1,1);
                        coun=0;
                        counn=0;
                        for i=1:n_ele
                            error_this=norm(scale_opt*R_opt*pts_3d(i,:)'+t_opt-pts_3d_(i,:)');
                            if error_this<=noise*1.7*3
                                coun=coun+1;
                                inlier_set(coun)=i;
                                inlier_error(coun)=error_this;
                            else counn=counn+1;
                                outlier_error(counn)=error_this;
                            end
                        end
                        
                        
                        
                        break
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
    
    n_ele_=length(inlier_set);
    
    pts_3d_new=pts_3d(inlier_set,:);
    
    pts_3d_new_=pts_3d_(inlier_set,:);
    
    q_=zeros(3,1);
    p_=zeros(3,1);
    
    for i=1:n_ele_
        
        q_(1)=q_(1)+pts_3d_new_(i,1);
        q_(2)=q_(2)+pts_3d_new_(i,2);
        q_(3)=q_(3)+pts_3d_new_(i,3);
        
        p_(1)=p_(1)+pts_3d_new(i,1);
        p_(2)=p_(2)+pts_3d_new(i,2);
        p_(3)=p_(3)+pts_3d_new(i,3);
        
    end
    
    p_=p_/n_ele_;
    q_=q_/n_ele_;
    
    s_=zeros(n_ele_,1);s_weight=zeros(n_ele_,1);p_tilde=zeros(n_ele_,1);
    
    for i=1:n_ele_
        p_tilde(i)=norm(pts_3d_new(i,:)'-p_);
        s_(i)=norm(pts_3d_new_(i,:)'-q_)/p_tilde(i);
        s_weight(i)=p_tilde(i)^2/0.01;
    end
    
    scale_opt=0;
    
    for i=1:n_ele_
        scale_opt=scale_opt+s_(i)*s_weight(i);
    end
    
    scale_opt=scale_opt/sum(s_weight);
    
    H=zeros(3,3);
    for i=1:n_ele_
        H=H+(pts_3d_new(i,:)'-p_)*(pts_3d_new_(i,:)'-q_)';
    end
    
    [U,~,V]=svd(H);
    
    R_opt=V*U';
    
    t_opt=q_-scale_opt*R_opt*p_;
    
elseif known_scale==0
    
    noise_bound=4.5;
    
    noise_bound_=5;
    
    for itr_RANSAC=1:1e+10
        
        inlier_set=[];
        
        
        scale_set_this=randperm(n_ele,3);
        
        
        s_=zeros(3,1);s_weight=zeros(3,1);count_=0;p_tilde=zeros(3,1);mean_s=0;
        
        for i=1:2
            for j=i+1:3
                count_=count_+1;
                p_tilde(count_)=norm(pts_3d(scale_set_this(i),:)'-pts_3d(scale_set_this(j),:)');
                s_(count_)=norm(pts_3d_(scale_set_this(i),:)'-pts_3d_(scale_set_this(j),:)')/p_tilde(count_);
                s_weight(count_)=p_tilde(count_)^2/0.01;
                mean_s=mean_s+s_(count_)*s_weight(count_);
            end
        end
        
        mean_s=mean_s/sum(s_weight);
        
        
        if   max(s_)-min(s_)<=0.1*mean_s
            
            
            if   abs(s_(1)-s_(2))<=noise_bound*noise/p_tilde(1)+noise_bound*noise/p_tilde(2) && ...
                    abs(s_(1)-s_(3))<=noise_bound*noise/p_tilde(1)+noise_bound*noise/p_tilde(3) && ...
                    abs(s_(2)-s_(3))<=noise_bound*noise/p_tilde(2)+noise_bound*noise/p_tilde(3)
                
                v12=pts_3d(scale_set_this(2),:)-pts_3d(scale_set_this(1),:);
                X_axis=v12'/norm(v12);
                v13=pts_3d(scale_set_this(3),:)-pts_3d(scale_set_this(1),:);
                v23=cross(v12,v13);
                Y_axis=v23'/norm(v23);
                Z_axis=cross(X_axis,Y_axis);
                
                v12=pts_3d_(scale_set_this(2),:)-pts_3d_(scale_set_this(1),:);
                X_axis_=v12'/norm(v12);
                v13=pts_3d_(scale_set_this(3),:)-pts_3d_(scale_set_this(1),:);
                v23=cross(v12,v13);
                Y_axis_=v23'/norm(v23);
                Z_axis_=cross(X_axis_,Y_axis_);
                
                R_raw=[X_axis_,Y_axis_,Z_axis_]*[X_axis,Y_axis,Z_axis]';
                
                t_raw1=(pts_3d_(scale_set_this(1),:))'-mean_s*R_raw*((pts_3d(scale_set_this(1),:)))';
                t_raw2=(pts_3d_(scale_set_this(2),:))'-mean_s*R_raw*((pts_3d(scale_set_this(2),:)))';
                t_raw3=(pts_3d_(scale_set_this(3),:))'-mean_s*R_raw*((pts_3d(scale_set_this(3),:)))';
                
                
                if   norm(t_raw1 - t_raw2) <= noise*noise_bound_ && norm(t_raw1 - t_raw3) <= noise*noise_bound_ && ...
                        norm(t_raw2 - t_raw3) <= noise*noise_bound_
                    
                    
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
                        
                        s_=zeros(3,1);s_weight=zeros(3,1);count_=0;p_tilde=zeros(3,1);mean_s_=0;
                        
                        lee=length(inlier_set);
                        
                        for i=1:lee
                            
                            p_tilde(i)=norm(pts_3d(inlier_set(i),:)'-pts_3d(scale_set_add,:)');
                            s_(i)=norm(pts_3d_(inlier_set(i),:)'-pts_3d_(scale_set_add,:)')/p_tilde(i);
                            s_weight(i)=p_tilde(i)^2/0.01;
                            mean_s_=mean_s_+s_weight(i)*s_(i);
                            
                        end
                        
                        mean_s_=mean_s_/sum(s_weight);
                        
                        if    max(s_)-min(s_)<=0.1*mean_s_ && abs(mean_s-mean_s_)<=0.06*mean_s
                            
                            mean_t=(t_raw1+t_raw2+t_raw3)/3;
                            
                            if    abs(s_(1)-s_(2))<=noise_bound*noise/p_tilde(1)+noise_bound*noise/p_tilde(2) && ...
                                    abs(s_(1)-s_(3))<=noise_bound*noise/p_tilde(1)+noise_bound*noise/p_tilde(3) && ...
                                    abs(s_(2)-s_(3))<=noise_bound*noise/p_tilde(2)+noise_bound*noise/p_tilde(3) && ...
                                    norm(mean_s*R_raw*pts_3d(scale_set_add,:)'+mean_t-pts_3d_(scale_set_add,:)')<=1.2*noise_bound_*noise
                                
                                
                                
                                v12=pts_3d(scale_set_this(2),:)-pts_3d(scale_set_add,:);
                                X_axis=v12'/norm(v12);
                                v13=pts_3d(scale_set_this(3),:)-pts_3d(scale_set_add,:);
                                v23=cross(v12,v13);
                                Y_axis=v23'/norm(v23);
                                Z_axis=cross(X_axis,Y_axis);
                                
                                v12=pts_3d_(scale_set_this(2),:)-pts_3d_(scale_set_add,:);
                                X_axis_=v12'/norm(v12);
                                v13=pts_3d_(scale_set_this(3),:)-pts_3d_(scale_set_add,:);
                                v23=cross(v12,v13);
                                Y_axis_=v23'/norm(v23);
                                Z_axis_=cross(X_axis_,Y_axis_);
                                
                                R_raw1=[X_axis_,Y_axis_,Z_axis_]*[X_axis,Y_axis,Z_axis]';
                                
                                
                                
                                
                                v12=pts_3d(scale_set_this(2),:)-pts_3d(scale_set_add,:);
                                X_axis=v12'/norm(v12);
                                v13=pts_3d(scale_set_this(1),:)-pts_3d(scale_set_add,:);
                                v23=cross(v12,v13);
                                Y_axis=v23'/norm(v23);
                                Z_axis=cross(X_axis,Y_axis);
                                
                                v12=pts_3d_(scale_set_this(2),:)-pts_3d_(scale_set_add,:);
                                X_axis_=v12'/norm(v12);
                                v13=pts_3d_(scale_set_this(1),:)-pts_3d_(scale_set_add,:);
                                v23=cross(v12,v13);
                                Y_axis_=v23'/norm(v23);
                                Z_axis_=cross(X_axis_,Y_axis_);
                                
                                R_raw2=[X_axis_,Y_axis_,Z_axis_]*[X_axis,Y_axis,Z_axis]';
                                
                                
                                
                                v12=pts_3d(scale_set_this(1),:)-pts_3d(scale_set_add,:);
                                X_axis=v12'/norm(v12);
                                v13=pts_3d(scale_set_this(3),:)-pts_3d(scale_set_add,:);
                                v23=cross(v12,v13);
                                Y_axis=v23'/norm(v23);
                                Z_axis=cross(X_axis,Y_axis);
                                
                                v12=pts_3d_(scale_set_this(1),:)-pts_3d_(scale_set_add,:);
                                X_axis_=v12'/norm(v12);
                                v13=pts_3d_(scale_set_this(3),:)-pts_3d_(scale_set_add,:);
                                v23=cross(v12,v13);
                                Y_axis_=v23'/norm(v23);
                                Z_axis_=cross(X_axis_,Y_axis_);
                                
                                R_raw3=[X_axis_,Y_axis_,Z_axis_]*[X_axis,Y_axis,Z_axis]';
                                
                                if AngErr(R_raw,R_raw1)*180/pi<=7 && AngErr(R_raw,R_raw2)*180/pi<=7 && ...
                                        AngErr(R_raw,R_raw3)*180/pi<=7 && AngErr(R_raw1,R_raw2)*180/pi<=7 && ...
                                        AngErr(R_raw3,R_raw1)*180/pi<=7 && AngErr(R_raw2,R_raw3)*180/pi<=7
                                    
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
                        
                        
                        scale_set_this=inlier_set;
                        
                        q_=zeros(3,1);
                        p_=zeros(3,1);
                        
                        len=length(inlier_set);
                        
                        for i=1:len
                            
                            q_(1)=q_(1)+pts_3d_(scale_set_this(i),1);
                            q_(2)=q_(2)+pts_3d_(scale_set_this(i),2);
                            q_(3)=q_(3)+pts_3d_(scale_set_this(i),3);
                            
                            p_(1)=p_(1)+pts_3d(scale_set_this(i),1);
                            p_(2)=p_(2)+pts_3d(scale_set_this(i),2);
                            p_(3)=p_(3)+pts_3d(scale_set_this(i),3);
                            
                        end
                        
                        p_=p_/len;
                        q_=q_/len;
                        
                        s_=zeros(len,1);s_weight=zeros(len,1);p_tilde=zeros(len,1);
                        
                        for i=1:len
                            p_tilde(i)=norm(pts_3d(scale_set_this(i),:)'-p_);
                            s_(i)=norm(pts_3d_(scale_set_this(i),:)'-q_)/p_tilde(i);
                            s_weight(i)=p_tilde(i)^2/0.01;
                        end
                        
                        scale_opt=0;
                        
                        for i=1:len
                            scale_opt=scale_opt+s_(i)*s_weight(i);
                        end
                        
                        scale_opt=scale_opt/sum(s_weight);
                        
                        
                        inlier_set_raw=inlier_set;
                        
                        
                        n_ele_=length(inlier_set);
                        
                        pts_3d_new=pts_3d(inlier_set,:);
                        
                        pts_3d_new_=pts_3d_(inlier_set,:);
                        
                        
                        H=zeros(3,3);
                        for i=1:n_ele_
                            H=H+(pts_3d_new(i,:)'-p_)*(pts_3d_new_(i,:)'-q_)';
                        end
                        
                        [U,~,V]=svd(H);
                        
                        R_opt=V*U';
                        
                        t_opt=q_-scale_opt*R_opt*p_;
                        
                        inlier_set=zeros(1,1);
                        outlier_error=zeros(1,1);
                        inlier_error=zeros(1,1);
                        coun=0;
                        counn=0;
                        for i=1:n_ele
                            error_this=norm(scale_opt*R_opt*pts_3d(i,:)'+t_opt-pts_3d_(i,:)');
                            if error_this<=noise*1.7*3
                                coun=coun+1;
                                inlier_set(coun)=i;
                                inlier_error(coun)=error_this;
                            else counn=counn+1;
                                outlier_error(counn)=error_this;
                            end
                        end
                        
                        
                        
                        break
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
    
    n_ele_=length(inlier_set);
    
    pts_3d_new=pts_3d(inlier_set,:);
    
    pts_3d_new_=pts_3d_(inlier_set,:);
    
    q_=zeros(3,1);
    p_=zeros(3,1);
    
    for i=1:n_ele_
        
        q_(1)=q_(1)+pts_3d_new_(i,1);
        q_(2)=q_(2)+pts_3d_new_(i,2);
        q_(3)=q_(3)+pts_3d_new_(i,3);
        
        p_(1)=p_(1)+pts_3d_new(i,1);
        p_(2)=p_(2)+pts_3d_new(i,2);
        p_(3)=p_(3)+pts_3d_new(i,3);
        
    end
    
    p_=p_/n_ele_;
    q_=q_/n_ele_;
    
    s_=zeros(n_ele_,1);s_weight=zeros(n_ele_,1);p_tilde=zeros(n_ele_,1);
    
    for i=1:n_ele_
        p_tilde(i)=norm(pts_3d_new(i,:)'-p_);
        s_(i)=norm(pts_3d_new_(i,:)'-q_)/p_tilde(i);
        s_weight(i)=p_tilde(i)^2/0.01;
    end
    
    scale_opt=0;
    
    for i=1:n_ele_
        scale_opt=scale_opt+s_(i)*s_weight(i);
    end
    
    scale_opt=scale_opt/sum(s_weight);
    
    H=zeros(3,3);
    for i=1:n_ele_
        H=H+(pts_3d_new(i,:)'-p_)*(pts_3d_new_(i,:)'-q_)';
    end
    
    [U,~,V]=svd(H);
    
    R_opt=V*U';
    
    t_opt=q_-scale_opt*R_opt*p_;
    
end


end